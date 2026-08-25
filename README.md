# Social Market

A rede social colaborativa de ofertas de supermercado.

## Visão do produto

O **Social Market** é um aplicativo móvel onde os próprios usuários postam ofertas reais encontradas nos supermercados — produto, preço, mercado e foto opcional — e validam as ofertas uns dos outros ("confirmei esse preço"), mantendo os dados sempre atualizados. Tudo isso combinado com feed social e gamificação (pontos, badges e ranking).

Diferenciais frente aos apps utilitários existentes (Compare Compras, Super Panfletos etc.):

- **Colaboração aberta**: qualquer usuário posta e atualiza ofertas.
- **Validação colaborativa**: mecanismo de confirmação entre usuários para combater dados desatualizados.
- **Feed social**: ofertas em um feed, com interação da comunidade.
- **Gamificação**: pontos, badges e ranking incentivam contribuições de qualidade.

## Stack técnica

- [Flutter](https://flutter.dev) (SDK `^3.7.2`) — Dart
- [Firebase](https://firebase.google.com) — projeto `social-market-54482`, configurado para Android, iOS, Web, Windows e macOS
  - `firebase_core` — inicialização
  - `firebase_auth` + `firebase_ui_auth` — autenticação (E-mail e Google)
  - `google_sign_in` + `firebase_ui_oauth_google` — login com Google
- Próximas dependências (Fase 1): `cloud_firestore`, `firebase_storage`, `image_picker`, `flutter_riverpod`, `GoRouter`

## Como rodar

### Pré-requisitos

- Flutter SDK `^3.7.2`
- Um projeto Firebase configurado (o deste repositório já vem com a config versionada)
- Para login com Google no Android: SHA-1 do debug registrado no Firebase

### Passos

```bash
# Instalar dependências
flutter pub get

# Rodar em modo debug (dispositivo ou emulador conectado)
flutter run
```

### Login com Google (`GOOGLE_CLIENT_ID`)

O client ID do OAuth do Google é lido via `--dart-define` (ver `lib/core/config.dart`). Há um **default embutido para desenvolvimento**, então o login funciona sem configuração extra em dev. Para sobrescrever:

```bash
flutter run --dart-define=GOOGLE_CLIENT_ID=seu-client-id.apps.googleusercontent.com
```

> **Nota:** a configuração do Firebase (`android/app/google-services.json` e `lib/firebase_options.dart`) está **versionada neste repositório** — não é preciso rodar `flutterfire configure` para começar. Em produção, avalie mover essas chaves para fora do controle de versão.

## Estrutura do projeto

Atual:

```
lib/
├── main.dart              # Inicialização do Firebase + app
├── app.dart               # Widget raiz
├── auth_gate.dart         # Gate de autenticação (login → home)
├── home.dart              # Home pós-login
├── firebase_options.dart  # Config gerada pelo FlutterFire
└── core/
    ├── config.dart        # GOOGLE_CLIENT_ID via --dart-define
    └── theme.dart         # Tema do app
```

Planejada (a partir da Fase 1, feature-first):

```
lib/
├── core/                  # Tema, config, utilitários compartilhados
└── features/
    ├── auth/              # Autenticação
    ├── offers/            # Ofertas (postar, validar, feed)
    ├── stores/            # Mercados/supermercados
    └── profile/           # Perfil e gamificação
```

## Roadmap

| Fase | Escopo |
|------|--------|
| **0** | Limpeza e fundação (em conclusão) |
| **1** | Fundação técnica: Firestore, Storage, image_picker, Riverpod, GoRouter, estrutura feature-first |
| **2** | Modelo de dados Firestore: `users`, `stores`, `offers` + security rules |
| **3** | Telas MVP: shell com BottomNav, Nova Oferta, Perfil |
| **4** | Qualidade: testes, `flutter analyze` limpo, E2E login→postar→console |

**Pós-MVP:** feed social, validação colaborativa de ofertas, gamificação (pontos/badges/ranking) e geolocalização.

## Como testar

```bash
# Testes unitários e de widget
flutter test

# Análise estática
flutter analyze
```
