{**************************************************

        File : devices.pas
  Developper : Saulo Popov Zambiasi
 Last Update : Feb/14/2002

 That is the program of devices. Each device has a
 different program, but has the same protocoll. If
 Device is a Sensor, then it will just send any
 informations about your detections. If Not, then
 will receive and send informations.

 UPDATE:

    0 - Nothing updated
    1 - Device whas turnned off
    2 - Device whas turnned on
    3 - Level 1 whas changged (consider then is on)
    4 - Level 2 whas changged
    5 - Level 1 and 2 whas changed
    6 - Device Sleep
    7 - Device wake up

**************************************************}


UNIT Devices;

INTERFACE

TYPE
   PDevice = ^ODevice;
   ODevice = Object
      On     : Byte;   { State on|off          }
      Level1 : Byte;   { Value Level 1         }
      Level2 : Byte;   { Value Level 2         }
      Update : Byte;   { Information updated   }
      Command: String; { If voice, command     }
      Change : Boolean;
      Constructor Init;
      Procedure   Run; Virtual;
      Procedure   Show; Virtual;
      Procedure   SetOn(b : Boolean);
      Procedure   SetLevel1(i : Byte);
      Procedure   SetLevel2(i : Byte);
      Procedure   SetComand(cmd : String);
      Function    Changed : Boolean;
      Destructor  Done;
   End;

IMPLEMENTATION

Constructor ODevice.Init;
Begin
   On     := 0;
   Level1 := 0;
   Level2 := 0;
   Update := 0;
   Command:= '';
   Change := False;
End;

Procedure ODevice.SetOn(b : Boolean);
Begin
   on     := Byte(b);
   Update := 1;
   Change := True;
End;

Procedure ODevice.SetLevel1(i : Byte);
Begin
   Level1 := i;
   Update := 1;
   Change := True;
End;

Procedure ODevice.SetLevel2(i : Byte);
Begin
   Level2 := i;
   Update := 1;
   Change := True;
End;

Procedure ODevice.SetComand(cmd : String);
Begin
   Command := cmd;
   Update  := 1;
   Change  := True;
End;

Procedure ODevice.Run;
Begin
End;

Procedure ODevice.Show;
Begin
End;

Function ODevice.Changed;
Begin
   Changed := Change;
   Change  := False;
End;

Destructor ODevice.Done;
Begin
End;

End.