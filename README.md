# JarlenModas

Guia de Execução do Projeto Flutter

Versões Necessárias
Para garantir a compatibilidade e o correto funcionamento do projeto, certifique-se de que as seguintes versões do Flutter e suas ferramentas associadas estão instaladas em seu ambiente de desenvolvimento:

- Flutter: 3.32.8  
- Dart: 3.8.1 

Você pode verificar suas versões atuais executando o seguinte comando no terminal:

flutter --version

Configuração Inicial
Siga os passos abaixo para preparar o ambiente do projeto:

Clone o Repositório:
Abra seu terminal ou prompt de comando e clone o projeto usando o Git. 

Navegue até o Diretório do Projeto

Instale as Dependências:

Execute o comando flutter pub get para baixar todas as dependências especificadas no arquivo pubspec.yaml do projeto:

flutter pub get

Executando o Projeto
Com as dependências instaladas, você pode iniciar a aplicação:

Verifique os Dispositivos Disponíveis:

Deve-se rodar a aplicação com windows

flutter run -d windows

A primeira compilação pode levar alguns minutos.

Verificação de Ambiente (flutter doctor): Se você encontrar problemas ou erros, execute flutter doctor para diagnosticar e obter sugestões sobre como corrigir sua configuração do ambiente Flutter.
flutter doctor

Configuração do firebase:

Rode esse comando para garantir que o flutterfire cli ta instalado :

dart pub global activate flutterfire_cli

Após rodar o comando acima na raiz do projeto rode o comando :

flutterfire configure
Ele deve pedir o login na conta, usando o login da conta e vinculando ao projeto jarlen-modas irá gerar o  lib/firebase_options.dart necessário para rodar o projeto.



