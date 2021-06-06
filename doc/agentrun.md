# Execução dos Agentes

## Executa no Pai

mensagemlida = falso
receba uma mensagem

se for comando entao

   se estiver dormindo entao
      se for pra acordar entao
         acorde
         proxima mensagem
      senao proxima mensagem
   senao se for pra acordar entao
      acorda
      proxima mensagem
   senao se estiver travado
      se for pra destravar entao
         destrave
         proxima mensagem
      senao se for pra dormir entao
         durma
         proxima mensagem
      senao proxima mensagem
   senao se for pra destravar entao
      destrava
      proxima mensagem

## Executa no filho

se a mensagem nao foi lida, entao
   se for comando entao
      executa comando
      proxima mensagem

   senao se for requisicao de informacoes entao
      responda
      proxima mensagem

   senao se for informacao
      analise informacao
      proxima mensagem

Executa suas operacoes
