{**********************************************

       File : samples.pas
 Developper : Saulo Popov Zambiasi
Last Update : Feb/15/2002

ELECTRODOMESTICS:

   Stove

   That things just obeys voice command



**********************************************}


UNIT Strove;


INTERFACE

USES
   LowLevel, Msg, Agents, Devices, MapDB;

TYPE

   PStrove = ^OStrove;
   OStrove = Object (OAgent)
      Grease  : Byte;
      Constructor Init(MS, AgType, Address : Byte; Dv : PDevice);
      Procedure   Run; Virtual;
      Procedure   Stop; Virtual;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OStrove.Init(MS, AgType, Address : Byte; Dv : PDevice);
Begin
   OAgent.Init(Ms, AgType, Address, Dv);
   Grease := 0;
End;

{**************************************************

   Run the opearations of Strove Agent

**************************************************}

Procedure OStrove.Run;

Var
   Mesg : Message;

Begin
   OAgent.Run;

   If (Not MesgLoaded) Then
   Begin
      GetBufferMesg(Mesg);

      If (Mesg <> 'NULL') Then
      Begin
         { If message is a voice command then execute}
         if (Mesg[MESG_TP] = 'C') Then
         Begin
            If (Mesg[CMD_ON]     <> #255) Then On     := Ord(Mesg[CMD_ON]);
            If (Mesg[CMD_LEVEL1] <> #255) Then Level1 := Ord(Mesg[CMD_LEVEL1]);
            If (Mesg[CMD_LEVEL2] <> #255) Then Level2 := Ord(Mesg[CMD_LEVEL2]);
            SetDevice;
            Dev^.Update := 1;
            NextBufferMesg;
         End
         { Else if message if anything else, then discard }
         Else NextBufferMesg;
      End;
   End;
   If (On = 1) Then
   Begin
      If (Grease <= 100) Then Grease := Grease + 1;
      If (Grease = 100) Then { Informa que ah gordura }
         MesgOut := MyID + Chr(Id[1]) + Chr(UNIT_GREASE) + #255 + 'C' + #1#255#255#255#255;
   End Else Begin
      If (Grease >= 1) Then Grease := Grease -1;
      If (Grease = 1) Then { Informa que nao ha mais gordura }
         MesgOut := MyID + Chr(Id[1]) + Chr(UNIT_GREASE) + #255 + 'C' + #0#255#255#255#255;
   End;

   Stop;
End;

{**************************************************

 Execute last functions to finich that moment task

***************************************************}

Procedure OStrove.Stop;
Begin
   OAgent.Stop;
End;

Destructor OStrove.Done;
Begin
   OAgent.Done;
End;

End.