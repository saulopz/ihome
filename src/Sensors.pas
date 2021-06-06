{**********************************************

       File : sensors.pas
 Developper : Saulo Popov Zambiasi
Last Update : Feb/14/2002

Assumption Architecture:



        +-------------+
     +--|Sleep|Wakeup |--+
     |  +-------------+  |
     |                   |
     |  +-------------+  |
     +--|Lock|Delock  |--+--+
     |  +-------------+     |
     |                      |
     |  +-------------+     |
     +--|Send Update  |-----+--+
     |  +-------------+        |
     |                         |
     |  +-------------+        |
 []--+--|Reply Message|--------+--->
        +-------------+


**********************************************}


UNIT Sensors;


INTERFACE

USES
   LowLevel, Msg, Agents, Devices, MapDB;

TYPE

   PSensor = ^OSensor;
   OSensor = Object (OAgent)
      Constructor Init(MS, AgType, Address : Byte; Dv : PDevice);
      Procedure   Run; Virtual;
      Procedure   Stop; Virtual;
      Function    SensorInfo : String;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OSensor.Init(MS, AgType, Address : Byte; Dv : PDevice);
Begin
   OAgent.Init(MS, AgType, Address, Dv);
End;

{**************************************************

   Run the opearations of Sensor Agent

**************************************************}

Procedure OSensor.Run;

Var Mesg : Message;

Begin
   OAgent.Run;

   { If not is a command to a sensor response }
   If (Not MesgLoaded) Then
   Begin
      GetBufferMesg(Mesg);
      //NextBufferMesg;
      If (Mesg <> 'NULL') Then                  
      Begin
         { If message is a command then execute }
         if ((Mesg[MESG_TP] = 'C') and (Mesg[RECEIV_TP] = Chr(Id[2]))) Then
         Begin
            If (Mesg[CMD_ON]     <> #255) Then On     := Ord(Mesg[CMD_ON]);
            If (Mesg[CMD_LEVEL1] <> #255) Then Level1 := Ord(Mesg[CMD_LEVEL1]);
            If (Mesg[CMD_LEVEL2] <> #255) Then Level2 := Ord(Mesg[CMD_LEVEL2]);
            SetDevice;
            Dev^.Update := 1;
            NextBufferMesg;
         End
         { Else if message if anything else, then discard }
         Else NextBufferMesg;
      End;
   End;

   { If device updated, send a information message to my MicroServer }
   If (Dev^.Update > 0) Then
   Begin
      MesgOut := Chr(Id[MY_MS]) + Chr(Id[MY_TP]) + Chr(Id[MY_ID]);
      MesgOut := MesgOut + Chr(Id[MY_MS]) + #255#255 + 'I';
      If (Id[2] = 2) Then MesgOut := SensorInfo
      Else MesgOut := MesgOut + SensorInfo;
      GetServerTime(Clock);
   End;
   Stop;
End;

{**************************************************

 Execute last functions to finich that moment task

***************************************************}

Procedure OSensor.Stop;
Begin
   OAgent.Stop;
End;

{**************************************************

   Make a structure of information dependding of
   type of sensor

***************************************************}

Function OSensor.SensorInfo : String;
Begin
   Case (Id[2]) of
      UNIT_PRESENCE : Begin
             SensorInfo := 'P' + Chr(On);
          End;
      UNIT_VOICE : Begin
             //MesgOut := MesgOut + 'C' + Dev^.Command;
             SensorInfo := Dev^.Command;
          End;
      UNIT_LIGHTNESS : Begin
             SensorInfo := 'L' + Chr(On);
          End;
      UNIT_TEMPERATURE : Begin
             SensorInfo := 'T' + Chr(Level1);
          End;
      UNIT_WATER : Begin
             SensorInfo := 'W' + Chr(On);
          End;
      UNIT_GREASE : Begin
             SensorInfo := 'G' + Chr(On);
          End;
      Else SensorInfo := '';
   End;
End;

Destructor OSensor.Done;
Begin
   OAgent.Done;
End;

End.