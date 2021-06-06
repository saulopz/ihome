{**********************************************

       File : window.pas
 Developper : Saulo Popov Zambiasi
Last Update : Feb/26/2002

WINDOWS AND DOORS

**********************************************}


UNIT Window;


INTERFACE

USES
   LowLevel, Msg, Agents, Devices;

TYPE

   PWindow = ^OWindow;
   OWindow = Object (OAgent)
      Constructor Init(MS, AgType, Address : Byte; Dv : PDevice);
      Procedure   Run; Virtual;
      Procedure   Stop; Virtual;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OWindow.Init(MS, AgType, Address : Byte; Dv : PDevice);
Begin
   OAgent.Init(MS, AgType, Address, Dv);
End;

{**************************************************

   Run the opearations of Window Agent

**************************************************}

Procedure OWindow.Run;

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
               MesgOut := MyID + Chr(Id[1]) + #255#255 + 'IS' + MakeInfoMesg;
               NextBufferMesg;
            End
            { Else if is a message from watter sensor }
            Else if ((Mesg[MESG_TP] = 'I') and (Mesg[MESG_SUBTP] = 'W')) Then
            Begin
               If (On = 1) Then
               Begin
                  On := Byte(Not Boolean(Mesg[INF_ON]));
                  MesgOut := MyID + Chr(Id[1]) + #255#255 + 'IS' + MakeInfoMesg;
               End;
               SetDevice;
               NextBufferMesg;
            End;
         End;
      End;
   End;

   Stop;
End;

{**************************************************

 Execute last functions to finich that moment task

***************************************************}

Procedure OWindow.Stop;
Begin
   OAgent.Stop;
End;

Destructor OWindow.Done;
Begin
   OAgent.Done;
End;

End.