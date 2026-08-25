# Social Market — Checklist E2E manual (PT-BL)

Roteiro de validação ponta a ponta do app contra o projeto Firebase real
(`social-market-54482`). Execute **antes de cada deploy de regras/release** e
sempre que mudar autenticação, repositórios, telas de oferta/mercado ou as
rules de Firestore/Storage.

## Pré-requisitos

1. **Firebase CLI** instalado e logado:
   ```powershell
   npm install -g firebase-tools
   firebase login
   ```
2. **Configuração FlutterFire já gerada** (`flutterfire configure` executado):
   `lib/firebase_options.dart` e `android/app/google-services.json` presentes.
   Não regenerar sem necessidade.
3. **SHA-1 do Google Sign-In**: o login com Google no Android exige a impressão
   digital SHA-1 do keystore registrada no Console
   (Authentication → Sign-in method → Google → adicionar impressão digital).
   Para obter a SHA-1 de debug:
   ```powershell
   keytool -list -v -alias androiddebugkey `
     -keystore "$env:USERPROFILE\.android\debug.keystore" `
     -storepass android -keypass android
   ```
   Após registrar a SHA-1, baixe novamente o `google-services.json`.
4. **Rodar o app** em dispositivo/emulador Android:
   ```powershell
   flutter run
   ```
5. Ter à mão um usuário de teste (crie na própria tela de login por e-mail/senha)
   e acesso ao Console do Firebase (Firestore e Storage) para conferir os dados.

## Checklist E2E numerado

1. [ ] **Login e-mail/senha cria `users/{uid}`**: faça login com e-mail/senha;
       no console, Firestore → coleção `users` deve conter documento com id =
       uid, campos `displayName`, `points: 0` e `createdAt`.
2. [ ] **Login Google cria `users/{uid}`**: saia, entre com Google; mesmo doc é
       criado/mantido (`photoUrl` presente se a conta tem foto). `points`
       continua 0 e não é sobrescrito em logins seguintes.
3. [ ] **Publicar oferta SEM foto**: aba Nova Oferta → produto, preço
       (ex.: `9,90`), unidade, cidade + busca ou "+ Cadastrar novo mercado" →
       Publicar. Em `offers/{id}`, conferir: `productName`, `price` numérico,
       `unit`, `storeId`, `authorUid == seu uid`, `confirmCount: 0`,
       `status: "active"` e campo `imageUrl` AUSENTE.
4. [ ] **Publicar oferta COM foto**: anexe uma imagem (< 5 MB) antes de
       publicar. No Storage deve surgir objeto em `offers/`
       (padrão `<timestamp>_<uid>.jpg`) e o documento da oferta deve ter
       `imageUrl` populada com URL acessível.
5. [ ] **Cadastro rápido de mercado**: "+ Cadastrar novo mercado" grava
       `stores/{id}` com `name`, `city`, `neighborhood`, `createdBy == seu uid`
       (e `nameSearch` em minúsculas, usado pela busca).
6. [ ] **Perfil mostra pontos = 0**: aba Perfil exibe nome, e-mail, card
       "0 pontos" e botão de sair.
7. [ ] **Edição manual indevida é bloqueada pelas rules**: no console, tente
       editar diretamente um documento (ex.: alterar `price`/`authorUid` de uma
       oferta ou `points` de um usuário) → deve retornar **PERMISSION_DENIED**.
       Teste também criar store com `createdBy` de outro usuário e deletar
       oferta alheia.

## Deploy das regras

As regras vivem na raiz: `firestore.rules` e `storage.rules` (mapeadas no
`firebase.json`).

```powershell
# Ambos de uma vez (sintaxe CLI v13+, alvos separados por espaço):
firebase deploy --only firestore:rules storage

# Ou individualmente:
firebase deploy --only firestore:rules
firebase deploy --only storage
```

- **Valide antes no simulador**: Console → Firestore → Regras → "Simulador".
  Simule create/update/delete em `users/{uid}`, `offers/{id}` e `stores/{id}`
  com "Autenticado" ligado/desligado e compare com o checklist acima.
- O deploy é atômico por serviço; regras novas valem imediatamente para todos
  os clientes (um app já aberto pode precisar ser reiniciado).
- Se o deploy falhar por permissão, confirme `firebase login` com a conta certa
  e o projeto ativo (`firebase use social-market-54482`).

## Emuladores (opcional)

Para desenvolver/testar sem tocar nos dados de produção:

1. Habilitar (uma única vez — adiciona bloco `emulators` ao `firebase.json`):
   ```powershell
   firebase init emulators
   ```
   Selecione **Authentication**, **Firestore** e **Storage** (portas padrão
   9099 / 8080 / 9199).
2. Subir:
   ```powershell
   firebase emulators:start
   ```
3. Apontar o app para os emuladores **somente em desenvolvimento** — ex.: com
   `--dart-define=USE_EMULATOR=true`, logo após `Firebase.initializeApp()` no
   `main.dart`:
   ```dart
   if (const bool.fromEnvironment('USE_EMULATOR')) {
     await FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);
     FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);
     await FirebaseStorage.instance.useStorageEmulator('10.0.2.2', 9199);
   }
   ```
   - `10.0.2.2` é o host da máquina visto pelo emulador Android; use
     `localhost` em desktop/web.
4. Dados do emulador são voláteis; persista com `--export-on-exit=./emulator-data`
   e recarregue com `--import=./emulator-data`.

> Observação: este passo exige alteração pontual em `main.dart` (guardada por
> flag) e não está habilitado por padrão neste repositório.
