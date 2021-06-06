{**********************************************

       File : samples.pas
 Developper : Saulo Popov Zambiasi
Last Update : Feb/15/2002

ELECTRODOMESTICS:

   Showwer

   LEVEL1 : [ 0-Desligado | 1-Verao | 3-Inverno ]
   LEVEL2 : [ Grau de temperatura ]

**********************************************}


UNIT showwer;


INTERFACE

USES
   LowLevel, Msg, Agents, Devices;

TYPE

   PShowwer = ^OShowwer;
   OShowwer = Object (OAgent)
      Temperature : Byte;
      Constructor Init(MS, AgType, Address : Byte; Dv : PDevice);
      Procedure   Run; Virtual;
      Procedure   Stop; Virtual;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OShowwer.Init(MS, AgType, Address : Byte; Dv : PDevice);
Begin
   OAgent.Init(Ms, AgType, Address, Dv);
End;

{**************************************************

   Run the opearations of Sample Agent

**************************************************}

Procedure OShowwer.Run;

Var
   Mesg : Message;

Begin
   OAgent.Run;

   If (Not MesgLoaded) Then
   Begin
      GetBufferMesg(Mesg);

      { if not sleepy and if not lock }
      If ((Not Sleepy) and (lock = 0)) Then
      Begin
         If (Mesg <> 'NULL') Then
         Begin
            { If message is a voice command then execute}
            if (Mesg[MESG_TP] = 'C') Then
            Begin
               If (Mesg[CMD_ON]     <> #255) Then On     := Ord(Mesg[CMD_ON]);
               If (Mesg[CMD_LEVEL1] <> #255) Then Level1 := Ord(Mesg[CMD_LEVEL1]);
               If (Mesg[CMD_LEVEL2] <> #255) Then Level2 := Ord(Mesg[CMD_LEVEL2]);
               SetDevice;
               NextBufferMesg;
            End
            { Else if is a message from temperature sensor }
            Else if ((Mesg[MESG_TP] = 'I') and (Mesg[MESG_SUBTP] = 'T')) Then
            Begin
               Temperature := Ord(Mesg[INF_ON]);
               If (Temperature < 20) Then Level1 := 2
               Else If (Temperature < 28) Then Level1 := 1
               Else Level1 := 0;
               If (Level1 = 0) Then Level2 := 0
               Else Level2 := 28 - Temperature;
               SetDevice;
               NextBufferMesg;
            End
            { Else if message if anything else, then discard }
            Else NextBufferMesg;
         End;
      End;
   End;

   If ((Not Sleepy) and (lock = 0)) Then
   Begin
      If ((Not Presence) and (On = 1)) Then
      Begin
         On := 0;
         SetDevice;
      End;
   End;

   Stop;
End;

{**************************************************

 Execute last functions to finich that moment task

***************************************************}

Procedure OShowwer.Stop;
Begin
   OAgent.Stop;
End;

Destructor OShowwer.Done;
Begin
   OAgent.Done;
End;

End.