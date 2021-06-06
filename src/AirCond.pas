{**********************************************

       File : aircond.pas
 Developper : Saulo Popov Zambiasi
Last Update : Feb/26/2002

ELETRODOMESTIC : Air-conditionning

**********************************************}


UNIT AirCond;


INTERFACE

USES
   LowLevel, Msg, Agents, Devices, MapDB;

CONST
   MAXTIME = 50;

TYPE
   PAirConditionning = ^OAirConditionning;
   OAirConditionning = Object (OAgent)
      WasOFF      : Boolean;
      TurnnedON   : Boolean;
      MesgOut2    : Message;
      MesgOut3    : Message;
      WinDoorOpen : Boolean;
      Temperature : Byte;
      TimeOut     : Byte;
      Constructor Init(MS, AgType, Address : Byte; Dv : PDevice);
      Procedure   Run; Virtual;
      Procedure   Stop; Virtual;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OAirConditionning.Init(MS, AgType, Address : Byte; Dv : PDevice);

Begin
   OAgent.Init(MS, AgType, Address, Dv);
   MesgOut2 := 'NULL';
   MesgOut2 := 'NULL';
   WinDoorOpen := False;
   TimeOut := 0;
End;


{**************************************************

   Run the opearations of AirConditionning Agent

**************************************************}

Procedure OAirConditionning.Run;

Var
   Mesg : Message;

Begin
   TurnnedOn := False;
   WasOff    := Not Boolean(On);

   OAgent.Run;

   If (Not MesgLoaded) Then
   Begin
      GetBufferMesg(Mesg);

      { if not sleepy and if not lock }
      If ((Not Sleepy) and (lock = 0)) Then
      Begin
         If (Mesg <> 'NULL') Then
         Begin
            { If Window is open then turn off air-conditionning }
            If ((Mesg[SENDER_TP] = Chr(UNIT_WINDOW)) or
                (Mesg[SENDER_TP] = Chr(UNIT_DOOR))) Then
            Begin
               If (Mesg[INF_ON] = #1) Then WinDoorOpen := True;
               If ((WinDoorOpen)) Then On :=  0
               Else
               Begin
                  If (Temperature > 25) Then
                  Begin
                     On     := 1;
                     Level1 := 1;
                     Level2 := Temperature - 25;
                  End
                  Else if (Temperature < 20) Then
                  Begin
                     On     := 1;
                     Level1 := 2;
                     Level2 := 20 - Temperature;
                  End;
               End;
               SetDevice;
               NextBufferMesg;
            End
            { If message is a voice command then execute}
            Else if (Mesg[MESG_TP] = 'C') Then
            Begin
               If (Mesg[CMD_ON]     <> #255) Then On     := Ord(Mesg[CMD_ON]);
               If (Mesg[CMD_LEVEL1] <> #255) Then Level1 := Ord(Mesg[CMD_LEVEL1]);
               If (Mesg[CMD_LEVEL2] <> #255) Then Level2 := Ord(Mesg[CMD_LEVEL2]);
               SetDevice;
               NextBufferMesg;

               If (On = 1) Then
               Begin
                  WinDoorOpen := False;
                  TimeOut := MAXTIME;
                  { then close all windows }
                  MesgOut := Chr(Id[1]) + Chr(Id[2]) + Chr(Id[3]) +
                              Chr(Id[1]) + Chr(UNIT_WINDOW) + #255 +
                              'C' + #0#255#255#255#255;
                  { then close all doors }
                  MesgOut2 := Chr(Id[1]) + Chr(Id[2]) + Chr(Id[3]) +
                             Chr(Id[1]) + Chr(UNIT_DOOR) + #255 +
                             'C' + #0#255#255#255#255;
               End;
            End
            { Else if is a message from temperature sensor }
            Else if ((Mesg[MESG_TP] = 'I') and (Mesg[MESG_SUBTP] = 'T')) Then
            Begin
               Temperature := Ord(Mesg[INF_ON]);
               { If temperature is hot or is cold}
               If ((Temperature > 25) or (Temperature < 20)) Then
               Begin
                  WinDoorOpen := False;
                  TimeOut := MAXTIME;
                  { Wait Window status }
                  MesgOut := Chr(Id[1]) + Chr(Id[2]) + Chr(Id[3]) +
                             Chr(Id[1]) + Chr(UNIT_WINDOW) + #255 + 'RS';
                  { Wait Door status }
                  MesgOut2 := Chr(Id[1]) + Chr(Id[2]) + Chr(Id[3]) +
                              Chr(Id[1]) + Chr(UNIT_DOOR) + #255 + 'RS';
               End Else Begin
                  { Turn off air-conditionning }
                  On     := 0;
                  Level1 := 0;
                  Level2 := 0;
                  SetDevice;
                  NextBufferMesg;
               End;
            End;
         End;
      End;
   End;

   If ((MesgOut2 <> 'NULL') and (MesgOut = 'NULL')) Then
   Begin
      MesgOut  := MesgOut2;
      MesgOut2 := 'NULL';
   End
   Else If ((MesgOut3 <> 'NULL') and (MesgOut = 'NULL')) Then
   Begin
      MesgOut  := MesgOut3;
      MesgOut3 := 'NULL';
   End;

   If (TimeOut > 0) Then dec(TimeOut)
   Else WinDoorOpen := False;

   Stop;
End;

{**************************************************

 Execute last functions to finich that moment task

***************************************************}

Procedure OAirConditionning.Stop;
Begin
   OAgent.Stop;
End;

Destructor OAirConditionning.Done;
Begin
   OAgent.Done;
End;

End.