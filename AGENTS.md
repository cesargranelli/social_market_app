# AGENTS.md — Diretrizes de trabalho

Convenções obrigatórias para agentes e contribuidores deste repositório.

## GitHub Issues — fluxo obrigatório

Toda issue criada por agentes deve:

1. **Ser associada ao projeto GitHub "Social Market"** (`cesargranelli/social_market_app`, owner `cesargranelli`).
   - Via CLI: `gh project item-add <numero-do-projeto> --owner cesargranelli --url <url-da-issue>`
   - Requer token com escopo Projects V2 (PAT fine-grained não acessa projetos de usuário — se falhar, sinalizar ao usuário).
2. **Ser assinada para @cesargranellidev**: `gh issue edit <n> --add-assignee cesargranellidev`
3. **Ter branch vinculada em Development** (criada via CLI, já aparece na seção Development da issue):
   - `gh issue develop <n> --name <nome-branch> --base main`
   - Convenção de nome: kebab-case descritivo (ex.: `fase-1-fundacao-tecnica`, `feat-nova-oferta`).

## Organização

- Roadmap por **milestones** (Fase 0–4, Pós-MVP); issues de fase herdam o milestone correspondente.
- Labels: `documentation` p/ docs/análise, `enhancement` p/ features.
- Issues concluídas: fechar com `--reason completed` + comentário referenciando commit hash.

## Commits

- Mensagens curtas em PT-BR minúsculo (ex.: `fase 0: limpeza da base...`).
- Push em `origin/main` após trabalho aprovado pelo usuário.

## Projeto

- App: Social Market — rede social colaborativa de ofertas de supermercado (ver README.md).
- Stack: Flutter + Firebase. Estrutura feature-first planejada em `lib/features/{auth,offers,stores,profile}`.
- Qualidade mínima antes de qualquer PR/commit de código: `flutter analyze` sem issues + `flutter test` verde.
