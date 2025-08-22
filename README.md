# JarlenModas

Guia de Execução do Projeto Flutter
Este documento fornece as instruções para configurar e executar o projeto Flutter em sua máquina local.

Versões Necessárias
Para garantir a compatibilidade e o correto funcionamento do projeto, certifique-se de que as seguintes versões do Flutter e suas ferramentas associadas estão instaladas em seu ambiente de desenvolvimento:

Flutter: 3.32.8

Canal: stable

Revisão do Framework: edada7c56e (4 semanas atrás) - 2025-07-25 14:08:03 +0000

Revisão do Engine: ef0cd00091 (4 semanas atrás) - 2025-07-24 12:23:50 -0700

Dart: 3.8.1

DevTools: 2.45.1

Você pode verificar suas versões atuais executando o seguinte comando no terminal:

flutter --version

Configuração Inicial
Siga os passos abaixo para preparar o ambiente do projeto:

Clone o Repositório:
Abra seu terminal ou prompt de comando e clone o projeto usando o Git. Substitua [URL_DO_SEU_REPOSITORIO] pelo link real do seu repositório:

git clone [URL_DO_SEU_REPOSITORIO]

Navegue até o Diretório do Projeto:
Após o clone, entre na pasta do projeto:

cd [nome-do-seu-projeto]

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

flutter run
# ou, para um dispositivo específico
flutter run -d [ID_DO_DISPOSITIVO]

A primeira compilação pode levar alguns minutos.

Dicas Adicionais
Hot Reload (r): Enquanto a aplicação estiver em execução, você pode pressionar r no terminal para aplicar pequenas mudanças no código quase instantaneamente, sem perder o estado da aplicação.

Hot Restart (R): Para mudanças mais significativas ou se o hot reload não funcionar, pressione R para reiniciar a aplicação do zero.

Verificação de Ambiente (flutter doctor): Se você encontrar problemas ou erros, execute flutter doctor para diagnosticar e obter sugestões sobre como corrigir sua configuração do ambiente Flutter.

flutter doctor

Documentação Oficial: Para informações mais detalhadas ou solução de problemas avançados, consulte a documentação oficial do Flutter.