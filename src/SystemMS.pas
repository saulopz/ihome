{**********************************************

       File : systemms.pas
 Developper : Saulo Popov Zambiasi
Last Update : Feb/14/2002

File Description:
   Operating System of MicroServer Web. With the
   function of manager of subsystem, agents. That
   is just a simulation environment.

MESSAGE MANAGER:

   If (msgMSid = MyMSid OR msgMSid = 255) then
      For each agent do
         If (msgSenderID <> AgentID) then
            If (msgType = agentType OR msgType = 255) then
               If (msgAgentID = agentID OR msgAgentID = 255) then
                  Send message to agent
               End If
            End if
         End if
      Next agent
   Else discard message

   OBS: Just send a message to who is destined


ARCHITECTURE:



           +--------------+
           | Super System |           -> 1 MicroServer
           +--------------+
             /    |     \
            /     |      \
           /      |       \
   +--------+ +--------+ +--------+
   |System 1| |System 2| |System n|   -> n MicroServers
   +--------+ +--------+ +--------+
              /   |    \
             /    |     \
            /     |      \
     +-------+ +-------+ +-------+
     |Agent 1| |Agent 2| |Agent n|    -> Implementation on System
     +-------+ +-------+ +-------+


   SUPER SYSTEM:

      Is the manager of all systems and agents,
      to solve conflits, make statistics and
      execute competitions.

      Exemple:
        A Agent "A" ask to super system:

        RR - Who X (TYPE) whas on more recently?

        Then super system ask to all TYPEs of all
        system:

        RS - All Agent, Send me your settings

        Then before agents send reply, the system makes a
        analisis in results and reply to agent "A".

   SYSTEM:

      Manager of many Agents implementeds inside
      that Micro Server. It is responsable to give
      time to execution to each agent of System. In
      general each System is on each locality of home.


   AGENT:

      Each agent have a control of each device in
      locality of home. It is implemented inside
      System.




**********************************************}


UNIT SystemMS;

INTERFACE

USES
  Devices, Agents, Sensors, Msg;


TYPE
   PMicroServer = ^OMicroServer;
   OMicroServer = Object
      Id    : Byte;
      Buffer: PBufferMessage;
      MsgOut: PBufferMessage;
      Size  : Byte;
      Point : PAgent;
      First : PAgent;
      Last  : PAgent;
      Next  : PMicroServer;
      Change: Boolean;
      Constructor Init;
      Procedure   Add(item : PAgent);
      Procedure   Run;
      Procedure   Send(Mesg : Message);
      Function    Receive : Message;
      Function    Changed : Boolean;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OMicroServer.Init;
Begin
   New(Buffer, Init);
   New(MsgOut, Init);
   Size   := 0;
   First  := nil;
   Point  := First;
   Last   := nil;
   Change := False;
End;

Procedure OMicroServer.Add(item : PAgent);

Var
  Pont : PAgent;
  Prev : PAgent;
  Vazio: Boolean;

Begin
   Prev := Nil;
   If (item <> Nil) Then
   Begin
      Inc(Size);
      Vazio := True;
      Pont  := First;
      While (Pont <> Nil) Do
      Begin
         Prev  := Pont;
         Pont  := Pont^.Next;
         Vazio := False;
      End;
      Pont := item;
      Pont^.Next := Nil;

      If Not Vazio Then Prev^.Next := Pont
      Else First  := Pont;
   End;
End;

Procedure OMicroServer.Run;

Var
   Mesg1 : Message;
   Mesg2 : Message;

Begin
   if (Size > 0) Then
   Begin
      Mesg1 := Buffer^.Get;
      Point := First;
      { Run each agent }
      While (Point <> Nil) Do
      Begin
         { If Server has a message to send and that message is
           addressed to that agent , then send it }
         If ((Mesg1 <> 'NULL') and
            ((Mesg1[RECEIV_MS] = Chr(Point^.Id[MY_MS])) or (Mesg1[RECEIV_MS] = #255))  and
            ((Mesg1[RECEIV_TP] = Chr(Point^.Id[MY_TP])) or (Mesg1[RECEIV_TP] = #255))  and
            ((Mesg1[RECEIV_ID] = Chr(Point^.Id[MY_ID])) or (Mesg1[RECEIV_ID] = #255))) Then
         Begin
            Point^.Send(Mesg1);
         End;

         { Run agent }
         Point^.Run;
         { If Agent has a message to send, then receive it }
         If (Point^.HasMesg) Then
         Begin
            Mesg2 := Point^.Receive;
            If (Mesg2[RECEIV_MS] = Chr(Id)) Then Buffer^.Add(Mesg2)
            Else MsgOut^.Add(Mesg2);
         End;
         If (Point^.Changed) Then Change := True;
         { Go to next agent }
         Point := Point^.Next;
      End;
   End;
End;

{**************************************************

  SuperServer send a message to MicroServer

***************************************************}

Procedure OMicroServer.Send(Mesg : Message);
Begin
   Buffer^.Add(Mesg);
End;


{**************************************************

   SuperServer receive a message from MicroServer

***************************************************}

Function OMicroServer.Receive : Message;
Begin
   Receive := MsgOut^.Get;
End;

Function OMicroServer.Changed : Boolean;
Begin
   Changed := Change;
   Change  := False;
End;

Destructor OMicroServer.Done;
Begin
   // Added in 23.07.2002
   Point := First;
   While (Point <> Nil) Do
   Begin
      Point := Point^.Next;
      Dispose(First, Done);
      First := Point;
   End;

   Dispose(MsgOut, Done);
   Dispose(Buffer, Done);
End;

End.
