{**********************************************

       File : videok7.pas
 Developper : Saulo Popov Zambiasi
Last Update : Feb/26/2002

    VIDEO K7, DVD, CABLE

**********************************************}


UNIT Videos;


INTERFACE

USES
   LowLevel, Msg, Agents, Devices, MapDB;

TYPE

   PVideo = ^OVideo;
   OVideo = Object (OAgent)
      TvOn      : Byte;
      TvLevel1  : Byte;
      TvLevel2  : Byte;
      TurnedOff : Boolean;
      FoundTV   : Boolean;
      Constructor Init(MS, AgType, Address : Byte; Dv : PDevice);
      Procedure   Run; Virtual;
      Procedure   Stop; Virtual;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OVideo.Init(MS, AgType, Address : Byte; Dv : PDevice);
Begin
   OAgent.Init(MS, AgType, Address, Dv);
   WasOn     := False;
   TvOn      := 0;
   TvLevel1  := 0;
   TvLevel2  := 0;
   TurnedOff := False;
   FoundTV   := False;
End;

{**************************************************

   Run the opearations of Video Agent

**************************************************}

Procedure OVideo.Run;

Var
   Mesg : Message;

Begin
   OAgent.Run;
   TurnedOff := False;

   If (Not MesgLoaded) Then
   Begin
      GetBufferMesg(Mesg);

      { if not sleepy and if not lock }
      If ((Not Sleepy) and (lock = 0)) Then
      Begin
         If (Mesg <> 'NULL') Then
         Begin
            If ((Mesg[SENDER_TP] = Chr(UNIT_TV)) and
                (Mesg[MESG_TP] = 'I') and
                (Mesg[MESG_SUBTP] = 'S')) Then
            Begin
               TvOn     := Ord(Mesg[INF_ON]);
               TvLevel1 := Ord(Mesg[INF_LEVEL1]);
               TvLevel2 := Ord(Mesg[INF_LEVEL2]);
               MesgOut := MyID + Chr(Id[1]) + #58#255+'C'+#01#254#255#255#255;
               FoundTV := True;
               On := 1;
               WasOn := True;
               SetDevice;
               NextBufferMesg;
            End
            { If message is a voice command then execute}
            Else if (Mesg[MESG_TP] = 'C') Then
            Begin
               TurnedOff := ((On = 1) and (Ord(Mesg[CMD_ON]) = 0));
               If (Mesg[CMD_ON]     <> #255) Then On := Ord(Mesg[CMD_ON]);
               If (Mesg[CMD_LEVEL1] <> #255) Then On := Ord(Mesg[CMD_LEVEL1]);
               If (Mesg[CMD_LEVEL2] <> #255) Then On := Ord(Mesg[CMD_LEVEL2]);
               SetDevice;
               NextBufferMesg;
               MesgOut := MyId + Chr(Id[1]) + Chr(UNIT_TV) + #255 + 'RS';
               WasOn := Boolean(On);
            End
            { Else if message if anything else, then discard }
            Else NextBufferMesg;
         End;
      End;
   End;

   { if not sleepy and if not lock }
   If ((Not Sleepy) and (lock = 0)) Then
   Begin
      If (Presence <> Pres) Then
      Begin
         If (Presence) Then
         Begin
            If (WasOn) Then
               MesgOut := MyId + Chr(Id[1]) + Chr(UNIT_TV) + #255 + 'RS'
         End
         Else If (On = 1) Then
         Begin
            On    := 0;
            TurnedOff := True;
            SetDevice;
         End;
      End;
   End;

   If (TurnedOff) Then
   Begin
      If (FoundTV) Then
      Begin
         MesgOut := MyID + Chr(Id[1]) + Chr(UNIT_TV) + #255+ 'C' +
            Chr(TvOn) + Chr(TvLevel1) + Chr(TvLevel2) + #255#255;
      End;
      TurnedOff := False;
   End;

   Stop;
End;

{**************************************************

 Execute last functions to finich that moment task

***************************************************}

Procedure OVideo.Stop;
Begin
   OAgent.Stop;
End;

Destructor OVideo.Done;
Begin
   OAgent.Done;
End;

End.