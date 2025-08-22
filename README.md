# JarlenModas

Guia de Execução do Projeto Flutter

Versões Necessárias
Para garantir a compatibilidade e o correto funcionamento do projeto, certifique-se de que as seguintes versões do Flutter e suas ferramentas associadas estão instaladas em seu ambiente de desenvolvimento:

Flutter: 3.32.8

Dart: 3.8.1

Você pode verificar suas versões atuais executando o seguinte comando no terminal:

flutter --version

Configuração Inicial
Siga os passos abaixo para preparar o ambiente do projeto:

Clone o Repositório:
Abra seu terminal ou prompt de comando e clone o projeto usando o Git. Substitua https://github.com/BaamOne/JarlenModas.git pelo link real do seu repositório:

git clone https://github.com/BaamOne/JarlenModas.git

Navegue até o Diretório do Projeto:
Após o clone, entre na pasta do projeto:

cd JarlenModas

Instale as Dependências:
Execute o comando flutter pub get para baixar todas as dependências especificadas no arquivo pubspec.yaml do projeto:

flutter pub get

Executando o Projeto
Com as dependências instaladas, você pode iniciar a aplicação:

Verifique os Dispositivos Disponíveis:
Conecte um dispositivo físico (Android ou iOS) ao seu computador ou inicie um emulador/simulador. Em seguida, liste os dispositivos disponíveis para execução:

flutter devices

Isso mostrará uma lista de dispositivos conectados ou emuladores rodando, com seus respectivos IDs.

Inicie a Aplicação:
Para rodar o projeto no dispositivo de sua escolha, utilize o comando flutter run. Se você tiver vários dispositivos, pode especificar o ID do dispositivo com a flag -d:

flutter run -d windows

A primeira compilação pode levar alguns minutos.

Verificação de Ambiente (flutter doctor): Se você encontrar problemas ou erros, execute flutter doctor para diagnosticar e obter sugestões sobre como corrigir sua configuração do ambiente Flutter.

flutter doctor
