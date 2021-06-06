{**********************************************

       File : vent.pas
 Developper : Saulo Popov Zambiasi
Last Update : Feb/26/2002

   VENTILATOR

**********************************************}


UNIT Vent;


INTERFACE

USES
   LowLevel, Msg, Agents, Devices, MapDB;

CONST
   MAXTIME = 50;

TYPE
   PVentilator = ^OVentilator;
   OVentilator = Object (OAgent)
      Temperature : Byte;
      MesgOut2    : Message;
      WinDoorOpen : Boolean;
      TimeOut     : Byte;
      Constructor Init(MS, AgType, Address : Byte; Dv : PDevice);
      Procedure   Run; Virtual;
      Procedure   Stop; Virtual;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OVentilator.Init(MS, AgType, Address : Byte; Dv : PDevice);
Begin
   OAgent.Init(MS, AgType, Address, Dv);
   MesgOut := 'NULL';
   WinDoorOpen := False;
   TimeOut := 0;
End;

{**************************************************

   Run the opearations of Ventilator Agent

**************************************************}

Procedure OVentilator.Run;

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
            { If windows and doors is open then turn on ventilator }
            If ((Mesg[SENDER_TP] = Chr(UNIT_WINDOW)) or
                (Mesg[SENDER_TP] = Chr(UNIT_DOOR))) Then
            Begin
               If (Mesg[INF_ON] = #1) Then WinDoorOpen := True;
               If ((WinDoorOpen) and (Presence) and
                  (Temperature > 25)) Then On := 1
               Else On := 0;
               SetDevice;
               NextBufferMesg;
            End
            { If message is a voice command then execute}
            Else if (Mesg[MESG_TP] = 'C') Then
            Begin
               If (Mesg[CMD_ON]     <> #255) Then On := Ord(Mesg[CMD_ON]);
               If (Mesg[CMD_LEVEL1] <> #255) Then On := Ord(Mesg[CMD_LEVEL1]);
               If (Mesg[CMD_LEVEL2] <> #255) Then On := Ord(Mesg[CMD_LEVEL2]);
               SetDevice;
               NextBufferMesg;
            End
            { Else if is a message from temperature sensor }
            Else if ((Mesg[MESG_TP] = 'I') and (Mesg[MESG_SUBTP] = 'T')) Then
            Begin
               { If temperature is hot or cold}
               Temperature := Ord(Mesg[INF_ON]);
               If (Temperature > 25) Then
               Begin
                  WinDoorOpen := False;
                  TimeOut := MAXTIME;
                  { Wait windows and doors status }
                  MesgOut  := Chr(Id[1]) + Chr(Id[2]) + Chr(Id[3]) +
                              Chr(Id[1]) + Chr(UNIT_WINDOW) + #255 + 'RS';
                  MesgOut2 := Chr(Id[1]) + Chr(Id[2]) + Chr(Id[3]) +
                              Chr(Id[1]) + Chr(UNIT_DOOR) + #255 + 'RS';
               End Else Begin
                  { Turn off ventilator }
                  Level1 := 0;
                  On     := 0;
                  SetDevice;
               End;
               NextBufferMesg;
            End;
         End;
      End;
   End;

   If ((Not Presence) and (On = 1)) Then
   Begin
      On := 0;
      SetDevice;
   End;

   If ((Presence <> Pres) and (Temperature > 25)) Then
   Begin
      WinDoorOpen := False;
      TimeOut := MAXTIME;
      { Wait windows and doors status }
      MesgOut := Chr(Id[1]) + Chr(Id[2]) + Chr(Id[3]) +
         Chr(Id[1]) + Chr(UNIT_WINDOW) + #255 + 'RS';
      MesgOut2 := Chr(Id[1]) + Chr(Id[2]) + Chr(Id[3]) +
         Chr(Id[1]) + Chr(UNIT_WINDOW) + #255 + 'RS';
   End;

   If ((MesgOut2 <> 'NULL') and (MesgOut = 'NULL')) Then
   Begin
      MesgOut  := MesgOut2;
      MesgOut2 := 'NULL';
   End;

   If (TimeOut > 0) Then dec(TimeOut)
   Else WinDoorOpen := False;

   Stop;
End;

{**************************************************

 Execute last functions to finich that moment task

***************************************************}

Procedure OVentilator.Stop;
Begin
   OAgent.Stop;
End;

Destructor OVentilator.Done;
Begin
   OAgent.Done;
End;

End.