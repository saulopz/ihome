{**********************************************

       File : sensors.pas
 Developper : Saulo Popov Zambiasi
Last Update : Feb/14/2002

LIGHT
   obedece - voice
   sente   - presence, lightness
   funcao
   - if presence[1] and lightness[0] then light[1]

**********************************************}


UNIT Lights;


INTERFACE

USES
   LowLevel, Msg, Agents, Devices;

TYPE

   PLight = ^OLight;
   OLight = Object (OAgent)
      Lightness   : Boolean;
      MyLightness : Boolean;
      Constructor Init(MS, AgType, Address : Byte; Dv : PDevice);
      Procedure   Run; Virtual;
      Procedure   Stop; Virtual;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OLight.Init(MS, AgType, Address : Byte; Dv : PDevice);

Begin
   OAgent.Init(Ms, AgType, Address, Dv);
   Lightness   := True;
   MyLightness := Lightness;
End;


{**************************************************

   Run the opearations of Light Agent

**************************************************}

Procedure OLight.Run;

Var
   Mesg : Message;

Begin
   OAgent.Run;

   If (Not MesgLoaded) Then
   Begin
      GetBufferMesg(Mesg);

      If (Mesg <> 'NULL') Then
      Begin
         { Se for informacao sobre luminosidade }
         If ((Mesg[MESG_TP] = 'I') and (Mesg[MESG_SUBTP] = 'L')) Then
         Begin
            { Set level of lightness }
            Lightness := Boolean(Mesg[INF_ON]);
            NextBufferMesg;
         End;

         { If message is a voice command then execute}
         If (Not MesgLoaded) Then
         Begin
            if (Mesg[MESG_TP] = 'C') Then
            Begin
               If (Mesg[CMD_ON]     <> #255) Then On := Ord(Mesg[CMD_ON]);
               If (Mesg[CMD_LEVEL1] <> #255) Then On := Ord(Mesg[CMD_LEVEL1]);
               If (Mesg[CMD_LEVEL2] <> #255) Then On := Ord(Mesg[CMD_LEVEL2]);
               SetDevice;
               NextBufferMesg;
            End;
         End;
      End;
   End;

   { If Not Sleepy and unlocked then execute }
   If ((Not Sleepy) and (lock = 0)) Then
   Begin
      If ((Presence <> Pres) or (Lightness <> MyLightness)) Then
      Begin
         On := Byte((Presence) and (Not Lightness));
         SetDevice;
         NextBufferMesg;
         MyLightness := Lightness;
      End;
   End;

   Stop;
End;

{**************************************************

 Execute last functions to finich that moment task

***************************************************}

Procedure OLight.Stop;
Begin
   OAgent.Stop;
End;

Destructor OLight.Done;
Begin
   OAgent.Done;
End;

End.