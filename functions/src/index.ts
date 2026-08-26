/**
 * Cloud Functions do Social Market — validação colaborativa de ofertas.
 *
 * Fluxo:
 * - Client grava offers/{offerId}/confirmations/{uid} (rules restringem a
 *   create/delete pelo próprio uid; ver firestore.rules).
 * - onConfirmationCreated/onConfirmationDeleted mantêm confirmCount na oferta,
 *   promovem status active -> verified ao cruzar o limiar e concedem pontos ao
 *   autor exatamente UMA vez por oferta.
 * - expireOffers roda agendado e marca ofertas vencidas como 'expired'.
 *
 * Decisões de design relevantes estão comentadas junto ao código.
 */
import { FirestoreEvent } from 'firebase-functions/v2/firestore';
import { onDocumentCreated, onDocumentDeleted } from 'firebase-functions/v2/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { logger } from 'firebase-functions';
import { getApps, initializeApp } from 'firebase-admin/app';
import {
  FieldValue,
  Firestore,
  QueryDocumentSnapshot,
  Timestamp,
  getFirestore,
} from 'firebase-admin/firestore';

if (getApps().length === 0) {
  // Em produção (gen2) o runtime provê FIREBASE_CONFIG/credenciais; em testes
  // offline o firebase-functions-test injeta FIREBASE_CONFIG via src/test-env.ts.
  initializeApp();
}

function db(): Firestore {
  return getFirestore();
}

/** Confirmações necessárias para a oferta virar 'verified'. */
export const VERIFICATION_THRESHOLD = 3;
/** Pontos concedidos ao autor quando a oferta é verificada pela primeira vez. */
export const REWARD_POINTS = 5;
/** Limite de documentos por batch write (cota do Firestore). */
const MAX_BATCH = 500;

interface OfferData {
  authorUid?: string;
  confirmCount?: number;
  status?: string;
  rewardGranted?: boolean;
}

/**
 * Aplica uma confirmação nova (create em confirmations/{uid}).
 *
 * Toda a decisão (novo count, transição de status e concessão de recompensa)
 * acontece DENTRO de uma transação com leitura prévia da oferta:
 * - evita corrida entre confirmações concorrentes que, lendo fora da
 *   transação, poderiam conceder os pontos duas vezes;
 * - FieldValue.increment segue atômico no servidor para o contador, então
 *   retries do trigger nunca perdem incrementos;
 * - rewardGranted vive no próprio doc da oferta e é setada na MESMA
 *   transação que concede os pontos => idempotente sob retry/concorrência.
 *
 * Exportado para testes unitários.
 */
export async function applyConfirmationCreated(
  store: Firestore,
  offerId: string,
  _confirmerUid: string,
): Promise<void> {
  const offerRef = store.collection('offers').doc(offerId);

  await store.runTransaction(async (tx) => {
    const snapshot = await tx.get(offerRef);
    if (!snapshot.exists) {
      // Oferta removida entre o write da confirmation e o disparo do trigger.
      return;
    }

    const data = (snapshot.data() ?? {}) as OfferData;
    const currentCount = typeof data.confirmCount === 'number' ? data.confirmCount : 0;
    const newCount = currentCount + 1;
    const prevStatus = data.status ?? 'active';

    const update: Record<string, unknown> = {
      confirmCount: FieldValue.increment(1),
    };

    // Status só avança active -> verified (nunca volta; expiry cuida do fim
    // de vida). Condição avaliada com a leitura de dentro da transação.
    if (newCount >= VERIFICATION_THRESHOLD && prevStatus === 'active') {
      update['status'] = 'verified';
    }

    const eligibleForReward =
      newCount >= VERIFICATION_THRESHOLD &&
      prevStatus !== 'expired' &&
      data.rewardGranted !== true;

    if (eligibleForReward) {
      update['rewardGranted'] = true;

      const authorUid = data.authorUid;
      if (typeof authorUid === 'string' && authorUid.length > 0) {
        const userRef = store.collection('users').doc(authorUid);
        const userSnap = await tx.get(userRef);
        if (userSnap.exists) {
          tx.update(userRef, { points: FieldValue.increment(REWARD_POINTS) });
        } else {
          // Fallback defensivo: usuário sem doc (cadastro incompleto).
          // Garante os pontos sem falhar o trigger.
          tx.set(userRef, {
            points: REWARD_POINTS,
            createdAt: FieldValue.serverTimestamp(),
          });
        }
        tx.set(userRef.collection('points_log').doc(), {
          reason: 'oferta_verificada',
          delta: REWARD_POINTS,
          offerId,
          at: FieldValue.serverTimestamp(),
        });
        logger.info('Recompensa concedida', { offerId, authorUid });
      } else {
        // Sem autor conhecido não há quem pontuar; ainda assim marcamos a flag
        // para não tentar premiar novamente em eventos futuros.
        logger.warn('Oferta verificada sem authorUid válido', { offerId });
      }
    }

    tx.update(offerRef, update);
  });
}

/**
 * Reverte uma confirmação (delete em confirmations/{uid}).
 *
 * Escolha SIMPLES documentada: decremento cego via FieldValue.increment(-1).
 * Não há floor em zero nem rebaixamento de status:
 * - valores negativos são possíveis apenas em cenário raro (delete duplicado),
 *   aceito por simplicidade; a leitura prévia aqui traria corrida própria;
 * - 'verified' NÃO volta para 'active' se o count cair abaixo do limiar —
 *   transições de status são unidirecionais (active -> verified -> expired).
 * Se a oferta já foi excluída (cascade apaga subcoleções), ignoramos.
 *
 * Exportado para testes unitários.
 */
export async function applyConfirmationDeleted(
  store: Firestore,
  offerId: string,
): Promise<void> {
  const offerRef = store.collection('offers').doc(offerId);
  const snapshot = await offerRef.get();
  if (!snapshot.exists) {
    return;
  }
  await offerRef.update({ confirmCount: FieldValue.increment(-1) });
}

/**
 * Expira ofertas cujo expiresAt passou. Simplificação acordada: somente
 * status == 'active' é expirado (verified permanece como histórico validado).
 * Retorna a quantidade expirada. Exportado para testes unitários.
 */
export async function expireDueOffers(
  store: Firestore,
  now: Date,
): Promise<number> {
  const cutoff = Timestamp.fromDate(now);
  // Índice: equality(status) + range(expiresAt) usa merge de índices de campo
  // único; índice composto opcional (ver docs/functions.md).
  const snapshot = await store
    .collection('offers')
    .where('status', '==', 'active')
    .where('expiresAt', '<', cutoff)
    .get();

  const docs = snapshot.docs;
  for (let i = 0; i < docs.length; i += MAX_BATCH) {
    const batch = store.batch();
    for (const doc of docs.slice(i, i + MAX_BATCH)) {
      batch.update(doc.ref, { status: 'expired' });
    }
    await batch.commit();
  }
  return docs.length;
}

// ---------------------------------------------------------------------------
// Wrappers (triggers registrados). Corpos finos: toda regra está nas funções
// acima, que são testadas diretamente.
// ---------------------------------------------------------------------------

interface ConfirmationParams {
  offerId: string;
  uid: string;
}

/** Evento onCreate: snapshot pode vir indefinido conforme o SDK. */
type ConfirmationCreatedEvent = FirestoreEvent<
  QueryDocumentSnapshot | undefined,
  ConfirmationParams
>;

/** Evento onDelete: a assinatura do SDK também admite snapshot indefinido. */
type ConfirmationDeletedEvent = FirestoreEvent<
  QueryDocumentSnapshot | undefined,
  ConfirmationParams
>;

/**
 * Handler puro do evento onCreate — exportado para permitir teste unitário
 * direto do handler (sem depender de wrap/mocks profundos do SDK).
 */
export async function handleConfirmationCreated(
  event: ConfirmationCreatedEvent,
): Promise<void> {
  if (!event.data || !event.params?.offerId || !event.params?.uid) {
    return;
  }
  await applyConfirmationCreated(db(), event.params.offerId, event.params.uid);
}

/** Handler puro do evento onDelete — exportado para testes. */
export async function handleConfirmationDeleted(
  event: ConfirmationDeletedEvent,
): Promise<void> {
  if (!event.data || !event.params?.offerId) {
    return;
  }
  await applyConfirmationDeleted(db(), event.params.offerId);
}

/** Trigger onCreate: mantém confirmCount/status/pontuação do autor. */
export const onConfirmationCreated = onDocumentCreated(
  'offers/{offerId}/confirmations/{uid}',
  handleConfirmationCreated,
);

/** Trigger onDelete: decrementa confirmCount. */
export const onConfirmationDeleted = onDocumentDeleted(
  'offers/{offerId}/confirmations/{uid}',
  handleConfirmationDeleted,
);

/** Agendado: expira ofertas vencidas a cada hora (horário de Brasília). */
export const expireOffers = onSchedule(
  {
    schedule: 'every 60 minutes',
    timeZone: 'America/Sao_Paulo',
  },
  async () => {
    const expired = await expireDueOffers(db(), new Date());
    logger.info('expireOffers concluído', { expiradas: expired });
  },
);
