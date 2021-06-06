{**********************************************

       File : samples.pas
 Developper : Saulo Popov Zambiasi
Last Update : Feb/15/2002

ELECTRODOMESTICS:

   Coffe Maker
   Computer
   Clothes dryer
   Freezer

   That things just obeys voice command



**********************************************}


UNIT Samples;


INTERFACE

USES
   LowLevel, Msg, Agents, Devices;

TYPE

   PSample = ^OSample;
   OSample = Object (OAgent)
      Constructor Init(MS, AgType, Address : Byte; Dv : PDevice);
      Procedure   Run; Virtual;
      Procedure   Stop; Virtual;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OSample.Init(MS, AgType, Address : Byte; Dv : PDevice);
Begin
   OAgent.Init(Ms, AgType, Address, Dv);
End;

{**************************************************

   Run the opearations of Sample Agent

**************************************************}

Procedure OSample.Run;

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
            NextBufferMesg;
         End
         { Else if message if anything else, then discard }
         Else NextBufferMesg;
      End;
   End;

   Stop;
End;

{**************************************************

 Execute last functions to finich that moment task

***************************************************}

Procedure OSample.Stop;
Begin
   OAgent.Stop;
End;

Destructor OSample.Done;
Begin
   OAgent.Done;
End;

End.