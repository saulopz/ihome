{**********************************************

       File : agstime.pas
 Developper : Saulo Popov Zambiasi
Last Update : Feb/15/2002

ELECTRODOMESTICS:

   Microwave
   Clothes wash

   Sanples agentes with timer

**********************************************}


UNIT AgSTime;


INTERFACE

USES
   LowLevel, Msg, Agents, Devices;

TYPE
   PAgSTime = ^OAgSTime;
   OAgSTime = Object (OAgent)
      Counter : Integer;
      Constructor Init(MS, AgType, Address : Byte; Dv : PDevice);
      Procedure   Run; Virtual;
      Procedure   Stop; Virtual;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OAgSTime.Init(MS, AgType, Address : Byte; Dv : PDevice);
Begin
   OAgent.Init(Ms, AgType, Address, Dv);
   Counter := 0;
End;

{**************************************************

   Run the opearations of AgSTime Agent

**************************************************}

Procedure OAgSTime.Run;

Var Mesg : Message;

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
            If (Mesg[CMD_ON]     <> #255) Then On := Ord(Mesg[CMD_ON]);
            If (Mesg[CMD_LEVEL1] <> #255) Then
               Begin
                  Level1 := Ord(Mesg[CMD_LEVEL1]);
                  Counter := Level1 * 2;
               End;
            If (Mesg[CMD_LEVEL2] <> #255) Then Level2 := Ord(Mesg[CMD_LEVEL2]);
            SetDevice;
            NextBufferMesg;
         End
         { Else if message if anything else, then discard }
         Else NextBufferMesg;
      End;
   End;

   If (Counter > 0) Then dec(Counter)
   Else If (On = 1) Then
   Begin
      On     := 0;
      Level1 := 0;
      Level2 := 0;
      SetDevice;
   End;

   Stop;
End;

{**************************************************

 Execute last functions to finich that moment task

***************************************************}

Procedure OAgSTime.Stop;
Begin
   OAgent.Stop;
End;

Destructor OAgSTime.Done;
Begin
   OAgent.Done;
End;

End.