# Cloud Functions — Validação colaborativa de ofertas

Este módulo implementa o backend das confirmações colaborativas: o client grava
apenas `offers/{offerId}/confirmations/{uid}` e **toda** a contagem, promoção de
status e pontuação acontecem no servidor.

## Visão geral

| Function | Tipo | Gatilho | Efeito |
| --- | --- | --- | --- |
| `onConfirmationCreated` | Firestore trigger (v2) | create em `offers/{id}/confirmations/{uid}` | `confirmCount` +1; ao cruzar 3 com status `active`, promove para `verified` e concede +5 pontos ao autor **uma única vez** |
| `onConfirmationDeleted` | Firestore trigger (v2) | delete em `offers/{id}/confirmations/{uid}` | `confirmCount` −1 (sem rebaixar `verified`) |
| `expireOffers` | Scheduled (v2) | a cada 60 minutos, tz `America/Sao_Paulo` | ofertas `active` com `expiresAt < agora` viram `expired`; loga a contagem |

### Decisões de design

- **Transação com leitura prévia**: a decisão de promover status e conceder
  pontos acontece dentro de `runTransaction`, lendo a oferta antes. Isso elimina
  a corrida em que duas confirmações concorrentes premiariam o autor duas vezes.
- **Idempotência/retry**: `FieldValue.increment` é atômico (retries não perdem
  incrementos) e a flag `rewardGranted: true` é gravada na oferta **na mesma
  transação** que credita os pontos — retries ou eventos duplicados nunca pagam
  duas vezes.
- **Log de pontos**: cada recompensa cria um doc em
  `users/{authorUid}/points_log/{autoId}`
  `{reason: 'oferta_verificada', delta: 5, offerId, at: serverTimestamp}`,
  legível apenas pelo dono (ver `firestore.rules`).
- **Decremento simples no delete**: escolha documentada no código — decremento
  cego via `increment(-1)`; valores negativos são possíveis só em cenário raro
  de deletes duplicados e são aceitos. Se a oferta já foi excluída, o evento é
  ignorado.
- **Status unidirecional**: `active → verified → expired`. O client **nunca**
  escreve `verified` — somente as Functions (Admin SDK bypassa rules). As rules
  continuam permitindo ao autor do client apenas `active → expired`.

## Pré-requisitos

1. **Node.js >= 20** (`node --version`).
2. **Plano Blaze** no Firebase — obrigatório para scheduled functions
   (`expireOffers`). Sem Blaze, apenas os triggers do Firestore funcionam.
3. Firebase CLI: `npm install -g firebase-tools` e `firebase login`.

## Instalação e testes locais

```bash
cd functions
npm ci          # ou npm install na primeira vez
npm run build   # compila TypeScript -> lib/
npm test        # suíte unitária offline (jest + firebase-functions-test)
```

Os testes rodam em **modo offline**: `src/test-env.ts` injeta `FIREBASE_CONFIG`
e o módulo `firebase-admin/firestore` é substituído por um fake em memória
(`src/index.test.ts`) que resolve `FieldValue.increment`/`serverTimestamp`
exatamente como o servidor. Não há rede nem emulador envolvidos.

## Testar com o emulador de Functions

```bash
# na raiz do repo, com o emulador de Auth/Firestore já configurado:
firebase emulators:start --only functions,firestore
```

Em outro terminal, use o app/aponte o SDK para `127.0.0.1:8080` (Firestore) e
grave docs em `offers/{id}/confirmations/{uid}`: os triggers disparam no
emulador e você pode inspecionar `offers/{id}` (`confirmCount`, `status`,
`rewardGranted`), `users/{authorUid}/points` e `points_log`.
O comando `npm run serve` (dentro de `functions/`) faz build + sobe o emulador.

## Deploy

```bash
cd functions
npm run deploy     # firebase deploy --only functions
```

## Índices compostos

A query do `expireOffers` combina `status == 'active'` (igualdade) com
`expiresAt < now` (range). O Firestore resolve isso por merge dos índices de
campo único — **nenhum índice composto é obrigatório**. Em cenários de escala
com mais filtros, pode-se criar explicitamente:

```json
{
  "indexes": [
    {
      "collectionGroup": "offers",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "expiresAt", "order": "ASCENDING" }
      ]
    }
  ]
}
```

(adicionar em `firestore.indexes.json` caso seu projeto gerencie índices por
arquivo).

## Custos e limites relevantes

- Triggers cobram leitura/gravação por documento — o fluxo usa poucas operações
  por confirmação (1 transação + eventualmente 2 escritas de recompensa).
- O scheduled roda 24×/dia; a query varre somente vencidas pendentes.
