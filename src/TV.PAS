{**********************************************

       File : tv.pas
 Developper : Saulo Popov Zambiasi
Last Update : Feb/26/2002

TV - Sound Stereo

**********************************************}


UNIT tv;


INTERFACE

USES
   LowLevel, Msg, Agents, Devices;

TYPE
   PTv = ^OTv;
   OTv = Object (OAgent)
      Constructor Init(MS, AgType, Address : Byte; Dv : PDevice);
      Procedure   Run; Virtual;
      Procedure   Stop; Virtual;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OTv.Init(MS, AgType, Address : Byte; Dv : PDevice);
Begin
   OAgent.Init(MS, AgType, Address, Dv);
End;

{**************************************************

   Run the opearations of Tv Agent

**************************************************}

Procedure OTv.Run;

Var Mesg : Message;

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
            { If message is a null response, then reset status }
            If ((Mesg[MESG_TP] = 'I') and (Mesg[MESG_SUBTP] = 'N')) Then
            Begin
               Status := 'FREE';
               NextBufferMesg;
            End
            { If is waitting SuperServer send a address }
            Else If (Status = 'WIA') Then
            Begin
               If ((Mesg[MESG_TP] = 'I') and (Mesg[MESG_SUBTP] = 'A')) Then
               Begin
                  { ask for informations from Address }
                  MesgOut := MyId + Mesg[AGENT_MS] + Mesg[AGENT_TP] +
                             Mesg[AGENT_ID] + 'RS';
                  Status  := 'WIS' + Mesg[AGENT_MS] + Mesg[AGENT_TP] +
                             Mesg[AGENT_ID];
                  NextBufferMesg;
               End;
            End
            { If is waitting informations }
            Else If ((Status[1] = 'W') and (Status[2] = 'I') and (Status[3] = 'S')) Then
            Begin
                If ((Mesg[SENDER_MS] = Status[4])  and
                    (Mesg[SENDER_TP] = Status[5])  and
                    (Mesg[SENDER_ID] = Status[6])) Then
                Begin
                   If (Mesg[INF_ON] = #1) Then
                   Begin
                      On     := 1;
                      Level1 := Ord(Mesg[INF_LEVEL1]);
                      Level2 := Ord(Mesg[INF_LEVEL2]);
                      SetDevice;
                      NextBufferMesg;
                      WasOn := True;
                   End;
                End;
            End
            { If message is a voice command then execute}
            Else if (Mesg[MESG_TP] = 'C') Then
            Begin
               If (Mesg[CMD_ON]     <> #255) Then On     := Ord(Mesg[CMD_ON]);
               If (Mesg[CMD_LEVEL1] <> #255) Then Level1 := Ord(Mesg[CMD_LEVEL1]);
               If (Mesg[CMD_LEVEL2] <> #255) Then Level2 := Ord(Mesg[CMD_LEVEL2]);
               SetDevice;
               NextBufferMesg;
               WasOn := Boolean(On);
            End
            { Else if message if anything else, then discard }
            Else NextBufferMesg;
         End;
      End;
   End;

   { If Anybody get in or get out place, then }
   If ((Not Sleepy) and (lock = 0)) Then
   Begin
      if (presence <> pres) Then
      Begin
         if (presence) Then
         Begin
            { Send a request to SuperServer, ask if has an
              video on any other place from home }
            MesgOut := MyId + #00#00#00 + 'RR' + Chr(Id[2])+ #255;
            Status  := 'WIA';
         End Else
         Begin
            On := 0;
            SetDevice;
         End;
      End;
   End;

   Stop;
End;

{**************************************************

 Execute last functions to finich that moment task

***************************************************}

Procedure OTv.Stop;
Begin
   OAgent.Stop;
End;

Destructor OTv.Done;
Begin
   OAgent.Done;
End;

End.