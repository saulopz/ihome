{**********************************************

       File : supersys.pas
 Developper : Saulo Popov Zambiasi
Last Update : Feb/27/2002

File Description:

      This is the manager of all systems and
      agents, to solve conflits, make statistics
      and execute competitions.

      Exemple:
        A Agent "A" ask to super system:

        RR - Who X (TYPE) whas on more recentl?

        Then super system ask to all TYPEs of all
        system:

        RS - All Agent, Send me your settings

        Then before agents send reply, the system makes a
        analisis in results and reply to agent "A".

**********************************************}


{

   ESTADOS DO "SUPER SISTEMA"

   - Livre;
   - Esperando Informacoes de "tipo" (5 tempos)


   EXECUCAO DO SUPER SISTEMA

   enviar, executar, receber

   Para cada Mensagem a enviar Fazer
      Para cada MicroServidor Fazer
         Se a mensagem for para este MicroServidor entao
             Enviar a mensagens

   Para cada MicroServidor Fazer
      Executar MicroServidor

   Para cada MicroServidor Fazer
      Para cada Mensagem a receber
         Receber a Mensagem

   Se esta LIVRE entao
      executar proxima requisicao
   Senao Pega informacoes (espera por 5 tempos)

   Se terminou espera, entao retorna o resultado

}


UNIT SuperSys;

INTERFACE

USES
  LowLevel, Devices, Msg, SystemMs, Agents,
  Sensors, AirCond, Extract, Lights, Samples,
  Tv, Vent, Videos, Window, Search;

CONST
   TIMEOUT = 10;

TYPE
   PSuperSys = ^OSuperSys;
   OSuperSys = Object
      Id       : Byte;
      Buffer   : PBufferMessage; { Messages to others Micro Systems }
      Request  : PBufferMessage; { Requests to super system }
      Info     : PBufferMessage; { Informations to super system }
      Size     : Byte;
      Point    : PMicroServer;
      First    : PMicroServer;
      Last     : PMicroServer;
      MySearch : PSearch;
      Change   : Boolean;
      Constructor Init;
      Procedure   Add(item : PMicroServer);
      Procedure   AddAgent(cod : Byte; item : PAgent);
      Function    GetMicroServer(cod : Byte) : PMicroServer;
      Function    Changed : Boolean;
      Procedure   Run;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OSuperSys.Init;
Begin
   New(Buffer,   Init);
   New(Request,  Init);
   New(Info,     Init);
   New(MySearch, Init);
   Size     := 0;
   First    := nil;
   Point    := First;
   Last     := nil;
   Change   := False;
End;

Procedure OSuperSys.Add(item : PMicroServer);

Var
  Pont : PMicroServer;
  Prev : PMicroServer;
  Vazio: Boolean;

Begin
   Prev := Nil;
   if (item <> nil) Then
   Begin
      Inc(Size);
      Vazio := True;
      Pont  := First;
      While Pont <> Nil Do
      Begin
         Prev := Pont;
         Pont := Pont^.Next;
         Vazio:= False;
      End;
      Pont := item;
      Pont^.Next := Nil;

      If Not Vazio Then Prev^.Next := Pont
      Else First  := Pont;
   End;
End;

Procedure OSuperSys.AddAgent(cod : Byte; item : PAgent);

Var
   Pont  : PMicroServer;
   Exist : Boolean;

Begin
   Exist := False;
   Pont  := First;
   While ((Pont <> Nil) and (Not Exist)) Do
   Begin
      If (Pont^.Id = cod) Then
      Begin
         Pont^.Add(item);
         Exist := True;
      End;
      Pont := Pont^.Next;
   End;
End;

Function OSuperSys.GetMicroServer(cod : Byte) : PMicroServer;

Var
   Pont : PMicroServer;
   ms   : PMicroServer;

Begin
   ms := Nil;
   Pont := First;
   While (Pont <> Nil) Do
   Begin
      If (Pont^.Id = cod) Then ms := Pont;
      Pont := Pont^.Next;
   End;
   GetMicroServer := ms;
End;

Procedure OSuperSys.Run;

Var Mesg  : Message;

Begin
   if (Size > 0) Then
   Begin
      { For each message }
      Mesg := Buffer^.Get;
      While (Mesg <> 'NULL') Do
      Begin
         { For each MicroServer }
         Point := First;
         While (Point <> Nil) Do
         Begin
            { If message is to this MicroServer, send then }
            If ((Mesg[RECEIV_MS] = Chr(Point^.Id)) or
                (Mesg[RECEIV_MS] = ALL)) Then
            Begin
               Point^.Send(Mesg);
            End;
            Point := Point^.Next;
         End;
         Mesg := Buffer^.Get;
      End;

      { For each MicroServer, execute then }
      Point := First;
      While (Point <> Nil) Do
      Begin
         Point^.Run;
         If (Point^.Changed) Then Change := True;
         Point := Point^.Next;
      End;

      { For each MicroServer, get Messages }
      Point := First;
      While (Point <> Nil) Do
      Begin
         Mesg := Point^.Receive;
         { For each message }
         While (Mesg <> 'NULL') Do
         Begin
            { If is a message to SuperSystem }
            If (Mesg[RECEIV_MS] = SUPER) Then
            Begin
               { If is a request }
               If (Mesg[MESG_TP] = 'R') Then MySearch^.Add(Mesg)
               { Else if is a information }
               Else MySearch^.Info(Mesg);
               If (MySearch^.HasRequest) Then
                  Buffer^.Add(MySearch^.GetRequest);
            End
            { Else if is to other MicroServers }
            Else Buffer^.Add(Mesg);
            Mesg := Point^.Receive;
         End;
         Point := Point^.Next
      End;
      MySearch^.Run;
      If (MySearch^.HasMessage) Then Buffer^.Add(MySearch^.GetMessage);
   End;
End;

Function OSuperSys.Changed : Boolean;
Begin
   Changed := Change;
   Change  := False;
End;

Destructor OSuperSys.Done;
Begin
   Point := First;
   While (Point <> Nil) Do
   Begin
      Point := Point^.Next;
      Dispose(First, Done);
      First := Point;
   End;

   Dispose(MySearch, Done);
   Dispose(Info,     Done);
   Dispose(Request,  Done);
   Dispose(Buffer,   Done);
End;


End.