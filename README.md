# StudyFlow — Rede de Estudos

Aplicativo Flutter para publicação e resposta de dúvidas escolares.

## Requisitos da atividade

- Firestore com coleção e subcoleção: `duvidas/{duvidaId}/respostas`
- Firebase Authentication com e-mail e senha
- SharedPreferences para a opção "Manter conectado"
- 2 consultas/filtros:
  1. `where('materia', isEqualTo: ...)`
  2. `where('autorId', isEqualTo: ...)`
- Interação multiusuário através de perguntas e respostas
- Respostas de respostas em níveis ilimitados

## Dependências

```bash
flutter pub get
```

Se ainda não adicionou as dependências:

```bash
flutter pub add firebase_core
flutter pub add firebase_auth
flutter pub add cloud_firestore
flutter pub add shared_preferences
```

## Configuração do Firebase

1. Crie um projeto no Firebase.
2. Ative Authentication > Sign-in method > Email/Password.
3. Crie o Cloud Firestore.
4. Instale/configure o FlutterFire CLI.
5. Execute:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Isso gera o arquivo `lib/firebase_options.dart`.

6. Substitua/publica as regras de `firestore.rules` no Firestore.
7. Rode:

```bash
flutter run
```

## Estrutura

```text
lib/
├── main.dart
├── firebase_options.dart  # gerado pelo FlutterFire
├── pages/
│   ├── login_page.dart
│   ├── cadastro_page.dart
│   ├── home_page.dart
│   ├── criar_duvida_page.dart
│   ├── duvida_page.dart
│   └── perfil_page.dart
├── services/
│   ├── auth_service.dart
│   └── firestore_service.dart
└── widgets/
    ├── duvida_card.dart
    └── resposta_item.dart
```

## Observação importante

`firebase_options.dart` não é incluído neste pacote porque ele é específico do projeto Firebase de cada aluno. Ele deve ser criado pelo comando `flutterfire configure`.
