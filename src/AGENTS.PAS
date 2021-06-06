{**********************************************

       File : agents.pas
 Developper : Saulo Popov Zambiasi
Last Update : Feb/14/2002

AGENT STATUS:

   FREE   - Free for all
   WISxxx - Waitting Settings from XXX
   WIAxxx - Waitting Agent address

OBSERVATIONS:

   Each Agent just can send one message and
   receive one message each time.

**********************************************}


Unit Agents;

INTERFACE

USES
   LowLevel, Msg, Devices;

CONST
    AGENT_MESG_SIZE = 10;
    STATUSTIMEOUT   = 30;

TYPE

   {**********************************************

   Agent Object -  This is an Object that represent
   a device control on the environment. That is the
   subsystem inside MicroServers.

   **********************************************}

   PAgent = ^OAgent;
   OAgent = Object
      Id         : Array[1..3] of Byte;
      On         : Byte;
      WasOn      : Boolean;
      auxOn      : Byte;
      Clock      : Time;
      Level1     : Byte;
      Level2     : Byte;
      Lock       : Byte;
      sleepy     : Boolean;
      status     : string[10];
      Mesgin     : Array[1..AGENT_MESG_SIZE] of Message;
      MesgIni    : 1..AGENT_MESG_SIZE+1;
      MesgEnd    : 1..AGENT_MESG_SIZE+1;
      MesgLoaded : Boolean;
      Presence   : Boolean;
      Pres       : Boolean;
      istatus    : Byte;
      Mesgout    : Message;
      Dev        : PDevice;
      Next       : PAgent; { Next agent in a circular list of agents }
      Change     : Boolean;

      Constructor Init(MS, AgType, Address : Byte; Dv : PDevice);
      Procedure   Run; Virtual;
      Procedure   Stop; Virtual;
      Procedure   Sleep;
      Procedure   WakeUp;
      Procedure   Send(Mesg : Message);
      Function    Changed : Boolean;
      Function    Receive : Message;
      Function    HasMesg : Boolean;
      Function    MakeInfoMesg : Message;
      Procedure   GetBufferMesg(Var Mesg : Message);
      Procedure   NextBufferMesg;
      Procedure   AddBufferMesg(Mesg : Message);
      Procedure   SetDevice;
      Procedure   GetDevice;
      Function    MyID : String;
      Destructor  Done;
   End;

CONST
   MY_MS = 1;
   MY_TP = 2;
   MY_ID = 3;

IMPLEMENTATION


{**************************************************

   Initalize the informations and variables of Object

***************************************************}

Constructor OAgent.Init(MS, AgType, Address : Byte; Dv : PDevice);
Begin
   Id[1]      := MS;
   Id[2]      := AgType;
   Id[3]      := Address;
   On         := 0;
   WasOn      := False;
   Level1     := 0;
   Level2     := 0;
   Lock       := 0;
   Sleepy     := False;
   status     := 'FREE';
   MesgIni    := 1;
   MesgEnd    := 1;
   Mesgout    := 'NULL';
   MesgLoaded := False;
   Presence   := False;
   Pres       := False;
   Dev        := dv;
   istatus    := 0;
   Next       := Nil;
   Change     := False;
   auxOn      := On;
   GetServerTime(Clock);
End;


{**************************************************

   Execute operations common of all Agents

***************************************************}

Procedure OAgent.Run;

Var
   Mesg : Message;

Begin
   MesgLoaded := False;
   GetBufferMesg(Mesg);

   {*** Verify commands to lock|unlock and sleep|wakeup}
   If (Mesg <> 'NULL') Then
   Begin
      { If message is a command then verify }
      if (Mesg[MESG_TP] = 'C') Then
      Begin
         { If is sleepy }
         If (Sleepy) Then
         Begin
            { If is to wake up then wake up}
            If (Mesg[CMD_SLEEP] = Chr(0)) Then
            Begin
               Wakeup;
               NextBufferMesg;
               Change := True;
            End Else NextBufferMesg;
         End
         { Else if is to sleep, then sleep }
         Else If (Mesg[CMD_SLEEP] = Chr(1)) Then
         Begin
            Sleep;
            Change := True;
            NextBufferMesg;
         End
         { Else if is lock }
         Else if (Lock = 1) Then
         Begin
            { if is to unlock then unlock }
            if (Mesg[CMD_LOCK] = Chr(0)) Then
            Begin
               Lock := 0;
               Change := True;
               NextBufferMesg;
            End;
         End
         { Else if is to lock, then lock }
         Else If (Mesg[CMD_LOCK] = Chr(1)) Then Begin
            Lock := 1;
            Change := True;
            NextBufferMesg;
         End;
      End
      { else if message is a requisition of information
        then send informations }
      Else if ((Mesg[MESG_TP] = 'R') and (Mesg[MESG_SUBTP] = 'S')) Then
      Begin
         MesgOut := MyID + Mesg[SENDER_MS] + Mesg[SENDER_TP] +
            Mesg[SENDER_ID] + 'IS' + MakeInfoMesg;
         If (Length(Mesg) = REQUEST_CODE) Then
            MesgOut := MesgOut + Mesg[REQUEST_CODE];
         NextBufferMesg;
      End
      Else if ((Mesg[MESG_TP] = 'I') and (Mesg[MESG_SUBTP] = 'P')) Then
      Begin
         Presence := Boolean(Mesg[INF_ON]);
         NextBufferMesg;
      End;
   End;
   { If device changed manualy, then wake up }
   If (Dev^.Update > 0) Then
   Begin
      GetDevice;
      Sleepy := False;
      Change := True;
   End;
End;


{**************************************************

   Finish the operations

***************************************************}

Procedure OAgent.Stop;

Var
   Mesg : Message;

Begin
   Pres := Presence;
   If (Not Sleepy) Then Dev^.Update := 0;

   { If exist a message on the buffer, and was not
     read any message in that time, elimin it }
   GetBufferMesg(Mesg);
   If ((Mesg <> 'NULL') and (Not MesgLoaded)) Then
      NextBufferMesg;

   { if agent is waitting a response, and the response
     do not come, then set agent free }
   if (Status <> 'FREE') Then istatus := istatus + 1
   Else istatus := 0;
   if (istatus > STATUSTIMEOUT) Then Status := 'FREE';

   If (auxOn <> On) Then
   Begin
      auxOn := On;
      GetServerTime(Clock);
   End;
End;

{**************************************************

   Turn Agent Sleepy

***************************************************}

Procedure OAgent.Sleep;
Begin
   Dev^.On := 0;
   Sleepy := True;
End;

{**************************************************

  Wake up Agent

***************************************************}

Procedure OAgent.WakeUp;
Begin
   If (On = 1) Then Dev^.On := 1;
   Sleepy := False;
End;


{**************************************************

  Micro Server send a message to agent

***************************************************}

Procedure OAgent.Send(Mesg : Message);
Begin
   AddBufferMesg(Mesg);
End;


{**************************************************

   Micro Server receive a message from agent

***************************************************}

Function OAgent.Receive : Message;
Begin
   Receive    := Mesgout;
   Mesgout := 'NULL';
End;


{**************************************************

   Get a message from buffer, if exist then

***************************************************}

Procedure OAgent.GetBufferMesg(Var Mesg : Message);
Begin
   If (MesgEnd <> MesgIni) Then Mesg := Mesgin[MesgIni]
   Else Mesg := 'NULL';
End;

{**************************************************

  Go to next message in buffer, erasing recently

***************************************************}

Procedure OAgent.NextBufferMesg;
Begin
   If (MesgEnd <> MesgIni) Then
   Begin
      MesgIni    := MesgIni+1;
      If (MesgIni = AGENT_MESG_SIZE+1) Then MesgIni := 1;
      MesgLoaded := True;
   End;
End;

{**************************************************

   If Buffer not completed, Include a new message

***************************************************}

Procedure OAgent.AddBufferMesg(Mesg : Message);

Var aux : Integer;

Begin
   aux := MesgEnd+1;
   If (aux = AGENT_MESG_SIZE+1) Then aux := 1;
   if (aux <> MesgIni) Then
   Begin
      Mesgin[MesgEnd] := Mesg;
      MesgEnd         := aux;
   End;
End;

{**************************************************

   Exist a message to agent send?

***************************************************}

Function OAgent.HasMesg : Boolean;
Begin
   HasMesg := MesgOut <> 'NULL';
End;

{**************************************************

   Join all informations about agent makking a
   message to be send when requisited.

***************************************************}

Function OAgent.MakeInfoMesg : Message;

Var
   Mesg   : Message;
   IH, IL : Byte;

Begin
   IL := Byte(Clock.Year and $FF00);
   IH := Byte((Clock.Year and $00FF) shr 8);
   If ((id[2] >= 58) and (id[2] <= 62)) Then Mesg := Chr(Byte(WasOn))
   Else Mesg := Chr(On);
   Mesg := Mesg + Chr(Clock.Hour) + Chr(Clock.Min) +
           Chr(Clock.Sec) + Chr(Clock.Day) + Chr(Clock.Month) +
           Chr(IH) + Chr(IL) + Chr(Level1) + Chr(Level2) +
           Chr(Lock) + Chr(Byte(Sleepy));
   MakeInfoMesg := Mesg;
End;

{**************************************************

   Set informations from device

***************************************************}

Procedure OAgent.SetDevice;
Begin
   If (Dev <> Nil) Then
   Begin
      Dev^.On     := On;
      Dev^.Level1 := Level1;
      Dev^.Level2 := Level2;
      Dev^.Command := '';
      Change := True;
   End;
End;

{**************************************************

   Get informations from Device and set agent

***************************************************}

Procedure OAgent.GetDevice;
Begin
   If (Dev <> Nil) Then
   Begin
      On     := Dev^.On;
      Level1 := Dev^.Level1;
      Level2 := Dev^.Level2;
   End;
End;

{**************************************************

   Get a string from Id of Agent, MS+TP+ID

***************************************************}

Function OAgent.MyID : String;
Begin
   MyID := Chr(Id[1]) + Chr(Id[2]) + Chr(Id[3]);
End;

Function OAgent.Changed : Boolean;
Begin
   Changed := Change;
   Change  := False;
End;

{**************************************************

   Erase and destruct a object from memory

***************************************************}

Destructor OAgent.Done;
Begin
{   Dispose(dev, done);}
End;

End.

