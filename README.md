# Agenda Telefônica

Aplicativo de agenda de contatos desenvolvido como **atividade acadêmica e projeto de estudo**. O objetivo é praticar desenvolvimento de interfaces e funcionalidades com Flutter e Dart, incluindo formulários, gerenciamento de estado, leitura de arquivos e integração com recursos do dispositivo.

O projeto é educacional e pode ter limitações; não foi concebido como um serviço de agenda de produção e foi desenvolvido exclusivamente para dispositivos móveis Android.

## Funcionalidades

- Cadastro, edição, consulta e exclusão de contatos.
- Dados de nome, telefone, e-mail, cidade, empresa, observações, aniversário, categorias e foto.
- Busca por nome, telefone ou e-mail e pesquisa avançada por categoria, cidade, empresa e período de cadastro.
- Favoritos, categorias e grupos de contatos.
- Consulta de aniversariantes do mês e dos próximos 30 dias.
- Importação e exportação de contatos em CSV e Excel.
- Importação da agenda do dispositivo Android, mediante permissão, com prevenção de duplicatas por telefone ou e-mail.
- Backup manual e backup automático com frequência diária ou semanal.
- Alternância entre tema claro e escuro, opção de lista compacta e controle da exibição de fotos.

## Tecnologias

- Flutter e Dart.
- `shared_preferences` para salvar preferências do aplicativo.
- `file_picker`, `csv` e `excel` para operações com arquivos.
- `image_picker` para selecionar ou tirar fotos.
- `flutter_contacts` para importar contatos do dispositivo.

## Como executar

É necessário ter o Flutter instalado e um dispositivo ou emulador configurado.

No terminal, entre na pasta do projeto Flutter e baixe as dependências:

```bash
cd Source/agenda
flutter pub get
```

Para iniciar o aplicativo:

```bash
flutter run -d chrome
```

Para gerar um novo APK Android (é necessário ter instalado o Android studio ou ferramentas de linha de comando ):

```bash
flutter build apk
```

## Observações

- A importação da agenda do dispositivo solicita permissão e está disponível para Android nesta configuração. No navegador, o aplicativo não acessa a agenda do dispositivo.
- Os contatos cadastrados ficam em memória durante a execução. Use a opção de backup ou exportação para guardar uma cópia dos dados.
- As preferências do aplicativo são salvas localmente no dispositivo.

## Contexto 

Este aplicativo foi criado para fins de aprendizagem e experimentação. As funcionalidades permitem estudar fluxos comuns de um aplicativo de contatos, como operações CRUD, filtros, preferências, arquivos, permissões e componentes de interface.
