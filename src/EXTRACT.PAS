{**********************************************

       File : extract.pas
 Developper : Saulo Popov Zambiasi
Last Update : Feb/26/2002

EXTRACTOR

**********************************************}


UNIT Extract;


INTERFACE

USES
   LowLevel, Msg, Agents, Devices;

TYPE

   PExtractor = ^OExtractor;
   OExtractor = Object (OAgent)
      Constructor Init(MS, AgType, Address : Byte; Dv : PDevice);
      Procedure   Run; Virtual;
      Procedure   Stop; Virtual;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OExtractor.Init(MS, AgType, Address : Byte; Dv : PDevice);
Begin
   OAgent.Init(Ms, AgType, Address, Dv);
End;


{**************************************************

   Run the opearations of Extractor Agent

**************************************************}

Procedure OExtractor.Run;

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
            { Else if is a message from grease sensor }
            Else if ((Mesg[MESG_TP] = 'I') and (Mesg[MESG_SUBTP] = 'G')) Then
            Begin
               On := Ord(Mesg[INF_ON]);
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

Procedure OExtractor.Stop;
Begin
   OAgent.Stop;
End;

Destructor OExtractor.Done;
Begin
   OAgent.Done;
End;

End.