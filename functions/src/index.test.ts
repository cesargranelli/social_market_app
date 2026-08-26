/**
 * Testes unitários (modo OFFLINE do firebase-functions-test).
 *
 * Estratégia:
 * - src/test-env.ts injeta FIREBASE_CONFIG antes de qualquer módulo (como o
 *   runtime/test lab faria), permitindo initializeApp() sem credenciais.
 * - O módulo 'firebase-admin/firestore' é substituído por um Firestore fake
 *   em memória (variável mockDb, permitida pelo padrão mock* do Jest).
 *   Assim testamos handlers e regras de negócio de forma determinística,
 *   incluindo os sentinels FieldValue.increment/serverTimestamp, que o fake
 *   resolve como o servidor resolveria.
 */
import fft from 'firebase-functions-test';

// Modo offline: valida carregamento/config das functions sem emulador.
const testEnv = fft();

// Variável precisa começar com "mock" para ser referenciável na fábrica abaixo.
let mockDb: FakeFirestore;

jest.mock('firebase-admin/firestore', () => ({
  getFirestore: () => mockDb,
  FieldValue: {
    increment: (amount: number) => ({ __sentinel: 'increment', amount }),
    serverTimestamp: () => ({ __sentinel: 'serverTimestamp' }),
  },
  Timestamp: {
    fromDate: (date: Date) => date.getTime(),
  },
}));

import type { Firestore, QueryDocumentSnapshot } from 'firebase-admin/firestore';
import * as index from './index';

// ---------------------------------------------------------------------------
// Firestore fake mínimo (apenas o que as funções usam)
// ---------------------------------------------------------------------------

type DocData = Record<string, unknown>;

interface IncrementSentinel {
  __sentinel: 'increment';
  amount: number;
}

function isIncrement(value: unknown): value is IncrementSentinel {
  return (
    typeof value === 'object' &&
    value !== null &&
    (value as IncrementSentinel).__sentinel === 'increment'
  );
}

const SERVER_TS = new Date('2026-01-01T00:00:00Z');

/** Resolve sentinels como o servidor faria contra o valor atual do campo. */
function resolveField(currentValue: unknown, newValue: unknown): unknown {
  if (isIncrement(newValue)) {
    const base = typeof currentValue === 'number' ? currentValue : 0;
    return base + newValue.amount;
  }
  if (
    typeof newValue === 'object' &&
    newValue !== null &&
    (newValue as { __sentinel?: string }).__sentinel === 'serverTimestamp'
  ) {
    return SERVER_TS;
  }
  return newValue;
}

class FakeDocSnapshot {
  constructor(
    private readonly store: Map<string, DocData>,
    readonly ref: FakeDocRef,
  ) {}

  get exists(): boolean {
    return this.store.has(this.ref.path);
  }

  data(): DocData | undefined {
    const raw = this.store.get(this.ref.path);
    return raw ? (JSON.parse(JSON.stringify(raw)) as DocData) : undefined;
  }
}

class FakeQuerySnapshot {
  constructor(
    readonly docs: Array<{ ref: FakeDocRef; id: string; data(): DocData }>,
  ) {}
}

class FakeDocRef {
  constructor(
    private readonly store: Map<string, DocData>,
    readonly segments: string[],
  ) {}

  get path(): string {
    return this.segments.join('/');
  }

  get id(): string {
    return this.segments[this.segments.length - 1];
  }

  collection(name: string): FakeCollectionRef {
    return new FakeCollectionRef(this.store, [...this.segments, name]);
  }

  async get(): Promise<FakeDocSnapshot> {
    return new FakeDocSnapshot(this.store, this);
  }

  /** Escrita síncrona (reutilizada por transação/batch). */
  applySet(data: DocData, opts?: { merge?: boolean }): void {
    if (opts?.merge) {
      const current = this.store.get(this.path) ?? {};
      this.store.set(this.path, { ...current, ...this.resolveFields(current, data) });
      return;
    }
    this.store.set(this.path, this.resolveFields({}, data));
  }

  /** Atualização síncrona: falha se o doc não existir (como no Firestore). */
  applyUpdate(data: DocData): void {
    const current = this.store.get(this.path);
    if (!current) {
      throw new Error(`NO_ENTITY_TO_UPDATE: ${this.path}`);
    }
    // Sentinels são resolvidos contra o valor ATUAL antes do merge,
    // exatamente como o servidor faria com FieldValue.increment.
    this.store.set(this.path, { ...current, ...this.resolveFields(current, data) });
  }

  applyDelete(): void {
    this.store.delete(this.path);
  }

  async set(data: DocData, opts?: { merge?: boolean }): Promise<void> {
    this.applySet(data, opts);
  }

  async update(data: DocData): Promise<void> {
    this.applyUpdate(data);
  }

  async delete(): Promise<void> {
    this.applyDelete();
  }

  private resolveFields(base: DocData, data: DocData): DocData {
    const resolved: DocData = {};
    for (const [key, value] of Object.entries(data)) {
      resolved[key] = resolveField(base[key], value);
    }
    return resolved;
  }
}

class FakeCollectionRef {
  constructor(
    private readonly store: Map<string, DocData>,
    private readonly segments: string[],
  ) {}

  get path(): string {
    return this.segments.join('/');
  }

  doc(id?: string): FakeDocRef {
    const docId = id ?? this.autoId();
    return new FakeDocRef(this.store, [...this.segments, docId]);
  }

  where(field: string, op: string, value: unknown): FakeQuery {
    return new FakeQuery(this.store, this.segments, [{ field, op, value }]);
  }

  private autoId(): string {
    return `auto-${mockDb.nextAutoId++}`;
  }
}

interface QueryFilter {
  field: string;
  op: string;
  value: unknown;
}

class FakeQuery {
  constructor(
    private readonly store: Map<string, DocData>,
    private readonly segments: string[],
    private readonly filters: QueryFilter[],
  ) {}

  where(field: string, op: string, value: unknown): FakeQuery {
    return new FakeQuery(this.store, this.segments, [
      ...this.filters,
      { field, op, value },
    ]);
  }

  async get(): Promise<FakeQuerySnapshot> {
    const prefix = `${this.path()}/`;
    const depth = this.segments.length + 1;
    const docs: Array<{ ref: FakeDocRef; id: string; data(): DocData }> = [];
    for (const [path, data] of this.store.entries()) {
      const segments = path.split('/');
      if (!path.startsWith(prefix) || segments.length !== depth) continue;
      if (!this.matches(data)) continue;
      const ref = new FakeDocRef(this.store, segments);
      docs.push({ ref, id: ref.id, data: () => ({ ...data }) });
    }
    return new FakeQuerySnapshot(docs);
  }

  private path(): string {
    return this.segments.join('/');
  }

  private matches(doc: DocData): boolean {
    return this.filters.every(({ field, op, value }) => {
      const current = doc[field];
      switch (op) {
        case '==':
          return current === value;
        case '<':
          return (current as number) < (value as number);
        default:
          throw new Error(`Filtro não suportado no fake: ${op}`);
      }
    });
  }
}

class FakeTransaction {
  private pendingWrites: Array<() => void> = [];

  async get(ref: FakeDocRef): Promise<FakeDocSnapshot> {
    return ref.get();
  }

  set(ref: FakeDocRef, data: DocData, opts?: { merge?: boolean }): this {
    this.pendingWrites.push(() => ref.applySet(data, opts));
    return this;
  }

  update(ref: FakeDocRef, data: DocData): this {
    this.pendingWrites.push(() => ref.applyUpdate(data));
    return this;
  }

  commit(): void {
    for (const write of this.pendingWrites) write();
  }
}

class FakeWriteBatch {
  private pendingWrites: Array<() => void> = [];

  update(ref: FakeDocRef, data: DocData): this {
    this.pendingWrites.push(() => ref.applyUpdate(data));
    return this;
  }

  async commit(): Promise<void> {
    for (const write of this.pendingWrites) write();
  }
}

class FakeFirestore {
  readonly docs = new Map<string, DocData>();
  nextAutoId = 1;

  collection(name: string): FakeCollectionRef {
    return new FakeCollectionRef(this.docs, [name]);
  }

  async runTransaction<T>(
    fn: (tx: FakeTransaction) => Promise<T>,
  ): Promise<T> {
    const tx = new FakeTransaction();
    const result = await fn(tx);
    tx.commit();
    return result;
  }

  batch(): FakeWriteBatch {
    return new FakeWriteBatch();
  }
}

// ---------------------------------------------------------------------------
// Helpers de fixture
// ---------------------------------------------------------------------------

function seedOffer(offerId: string, data: DocData): void {
  mockDb.docs.set(`offers/${offerId}`, { ...data });
}

function offerDoc(offerId: string): DocData {
  const data = mockDb.docs.get(`offers/${offerId}`);
  expect(data).toBeDefined();
  return data!;
}

function seedUser(uid: string, data: DocData): void {
  mockDb.docs.set(`users/${uid}`, { ...data });
}

function pointLogsOf(uid: string): string[] {
  return [...mockDb.docs.keys()].filter((path) =>
    path.startsWith(`users/${uid}/points_log/`),
  );
}

function confirmationEvent(
  offerId: string,
  uid: string,
  hasData = true,
): Parameters<typeof index.handleConfirmationCreated>[0] {
  return {
    params: { offerId, uid },
    data: hasData ? ({ exists: true } as QueryDocumentSnapshot) : undefined,
  } as unknown as Parameters<typeof index.handleConfirmationCreated>[0];
}

// ---------------------------------------------------------------------------
// Testes
// ---------------------------------------------------------------------------

describe('validação colaborativa (functions)', () => {
  beforeEach(() => {
    mockDb = new FakeFirestore();
  });

  afterAll(() => {
    testEnv.cleanup();
  });

  describe('applyConfirmationCreated', () => {
    test('abaixo do limiar: incrementa confirmCount sem promover status nem premiar', async () => {
      seedOffer('o1', { authorUid: 'autor', confirmCount: 1, status: 'active' });
      seedUser('autor', { points: 10 });

      await index.applyConfirmationCreated(
        mockDb as unknown as Firestore,
        'o1',
        'u9',
      );

      expect(offerDoc('o1')['confirmCount']).toBe(2);
      expect(offerDoc('o1')['status']).toBe('active');
      expect(offerDoc('o1')['rewardGranted']).toBeUndefined();
      expect(mockDb.docs.get('users/autor')!['points']).toBe(10);
      expect(pointLogsOf('autor')).toHaveLength(0);
    });

    test('ao cruzar 3 confirmações: vira verified e concede pontos UMA única vez', async () => {
      seedOffer('o1', { authorUid: 'autor', confirmCount: 2, status: 'active' });
      seedUser('autor', { points: 10 });

      // Confirmação nº 3 cruza o limiar.
      await index.applyConfirmationCreated(
        mockDb as unknown as Firestore,
        'o1',
        'u9',
      );

      expect(offerDoc('o1')['confirmCount']).toBe(3);
      expect(offerDoc('o1')['status']).toBe('verified');
      expect(offerDoc('o1')['rewardGranted']).toBe(true);
      expect(mockDb.docs.get('users/autor')!['points']).toBe(15);

      const logs = pointLogsOf('autor');
      expect(logs).toHaveLength(1);
      const log = mockDb.docs.get(logs[0])!;
      expect(log['reason']).toBe('oferta_verificada');
      expect(log['delta']).toBe(index.REWARD_POINTS);
      expect(log['offerId']).toBe('o1');
      expect(log['at']).toEqual(new Date('2026-01-01T00:00:00Z'));

      // Nova confirmação (count 4): NÃO duplica pontos nem cria novo log.
      await index.applyConfirmationCreated(
        mockDb as unknown as Firestore,
        'o1',
        'u10',
      );

      expect(offerDoc('o1')['confirmCount']).toBe(4);
      expect(mockDb.docs.get('users/autor')!['points']).toBe(15);
      expect(pointLogsOf('autor')).toHaveLength(1);
    });

    test('status verified se mantém mesmo com novas confirmações (transição única)', async () => {
      seedOffer('o1', { authorUid: 'autor', confirmCount: 3, status: 'verified', rewardGranted: true });

      await index.applyConfirmationCreated(
        mockDb as unknown as Firestore,
        'o1',
        'u9',
      );

      expect(offerDoc('o1')['confirmCount']).toBe(4);
      expect(offerDoc('o1')['status']).toBe('verified');
    });

    test('oferta expired: conta cresce mas não promove status nem premia', async () => {
      seedOffer('o1', { authorUid: 'autor', confirmCount: 2, status: 'expired' });
      seedUser('autor', { points: 10 });

      await index.applyConfirmationCreated(
        mockDb as unknown as Firestore,
        'o1',
        'u9',
      );

      expect(offerDoc('o1')['confirmCount']).toBe(3);
      expect(offerDoc('o1')['status']).toBe('expired');
      expect(offerDoc('o1')['rewardGranted']).toBeUndefined();
      expect(mockDb.docs.get('users/autor')!['points']).toBe(10);
    });

    test('autor sem documento de usuário: fallback cria doc com pontos e log', async () => {
      seedOffer('o1', { authorUid: 'novo-autor', confirmCount: 2, status: 'active' });

      await index.applyConfirmationCreated(
        mockDb as unknown as Firestore,
        'o1',
        'u9',
      );

      expect(mockDb.docs.get('users/novo-autor')!['points']).toBe(
        index.REWARD_POINTS,
      );
      expect(pointLogsOf('novo-autor')).toHaveLength(1);
    });

    test('oferta inexistente: não lança erro e não escreve nada', async () => {
      await expect(
        index.applyConfirmationCreated(
          mockDb as unknown as Firestore,
          'fantasma',
          'u9',
        ),
      ).resolves.toBeUndefined();
      expect(mockDb.docs.size).toBe(0);
    });
  });

  describe('applyConfirmationDeleted', () => {
    test('decrementa confirmCount ao remover confirmação', async () => {
      seedOffer('o1', { authorUid: 'autor', confirmCount: 3, status: 'verified' });

      await index.applyConfirmationDeleted(
        mockDb as unknown as Firestore,
        'o1',
      );

      expect(offerDoc('o1')['confirmCount']).toBe(2);
      // Status NÃO rebaixa (transições são unidirecionais).
      expect(offerDoc('o1')['status']).toBe('verified');
    });

    test('aceita negativo raro (decisão simples documentada no código)', async () => {
      seedOffer('o1', { authorUid: 'autor', confirmCount: 0, status: 'active' });

      await index.applyConfirmationDeleted(
        mockDb as unknown as Firestore,
        'o1',
      );

      expect(offerDoc('o1')['confirmCount']).toBe(-1);
    });

    test('oferta removida entre eventos: ignora silenciosamente', async () => {
      await expect(
        index.applyConfirmationDeleted(mockDb as unknown as Firestore, 'fantasma'),
      ).resolves.toBeUndefined();
      expect(mockDb.docs.size).toBe(0);
    });
  });

  describe('handlers finos (triggers)', () => {
    test('handleConfirmationCreated delega para a lógica com params do evento', async () => {
      seedOffer('o1', { authorUid: 'autor', confirmCount: 2, status: 'active' });
      seedUser('autor', { points: 0 });

      await index.handleConfirmationCreated(confirmationEvent('o1', 'u9'));

      expect(offerDoc('o1')['confirmCount']).toBe(3);
      expect(offerDoc('o1')['status']).toBe('verified');
    });

    test('handleConfirmationCreated sem snapshot (delete concorrente) é no-op', async () => {
      await expect(
        index.handleConfirmationCreated(confirmationEvent('o1', 'u9', false)),
      ).resolves.toBeUndefined();
      expect(mockDb.docs.size).toBe(0);
    });

    test('handleConfirmationDeleted delega para a lógica', async () => {
      seedOffer('o1', { authorUid: 'autor', confirmCount: 2, status: 'active' });

      const event = {
        params: { offerId: 'o1', uid: 'u9' },
        data: { exists: true } as QueryDocumentSnapshot,
      } as unknown as Parameters<typeof index.handleConfirmationDeleted>[0];

      await index.handleConfirmationDeleted(event);

      expect(offerDoc('o1')['confirmCount']).toBe(1);
    });

    test('triggers e scheduled estão registrados', () => {
      expect(typeof index.onConfirmationCreated).toBe('function');
      expect(typeof index.onConfirmationDeleted).toBe('function');
      expect(typeof index.expireOffers).toBe('function');
    });
  });

  describe('expireDueOffers', () => {
    test('expira somente ofertas active com expiresAt no passado', async () => {
      const now = new Date('2026-08-25T12:00:00Z');
      const pastMs = new Date('2026-08-24T12:00:00Z').getTime();
      const futureMs = new Date('2026-08-26T12:00:00Z').getTime();

      seedOffer('a1', { status: 'active', expiresAt: pastMs });
      seedOffer('a2', { status: 'active', expiresAt: pastMs });
      // verified vencida: fora do escopo da simplificação acordada.
      seedOffer('v1', { status: 'verified', expiresAt: pastMs });
      seedOffer('f1', { status: 'active', expiresAt: futureMs });
      seedOffer('e1', { status: 'expired', expiresAt: pastMs });

      const expired = await index.expireDueOffers(
        mockDb as unknown as Firestore,
        now,
      );

      expect(expired).toBe(2);
      expect(offerDoc('a1')['status']).toBe('expired');
      expect(offerDoc('a2')['status']).toBe('expired');
      expect(offerDoc('v1')['status']).toBe('verified');
      expect(offerDoc('f1')['status']).toBe('active');
      expect(offerDoc('e1')['status']).toBe('expired');
    });

    test('sem ofertas vencidas: retorna zero', async () => {
      seedOffer('f1', {
        status: 'active',
        expiresAt: new Date('2026-09-01T12:00:00Z').getTime(),
      });

      const expired = await index.expireDueOffers(
        mockDb as unknown as Firestore,
        new Date('2026-08-25T12:00:00Z'),
      );

      expect(expired).toBe(0);
      expect(offerDoc('f1')['status']).toBe('active');
    });
  });
});
