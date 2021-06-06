unit USectors;

interface

USES
   MapDB, ImgDB, Devices, Collects, Config, SystemMS, SuperSys,
   Agents, Sensors, Tv, AirCond, Extract, Lights, Vent, Videos,
   Window, Samples, Strove, Showwer, AgSTime;


TYPE
   PElementSector = ^TElementSector;
   TElementSector = Record
      Code     : Byte;
      UnitType : Byte;
      Dev      : PDevice;
      Next     : PElementSector;
   End;

   PSector = ^OSector;
   OSector = Object
      Size  : Integer;
      Point : PElementSector;
      First : PElementSector;
      Last  : PElementSector;
      Super : OSuperSys;
      Constructor Init;
      Procedure   Add(sec : Byte; uType : Byte; dev : PDevice);
      Procedure   InsertItem(item : PElementSector);
      Procedure   InsertAgent(sec, uType : Byte; dev : PDevice);
      Procedure   CommandVoice(sec : Byte; cmd : String);
      Procedure   SetDevice(uType: Byte;  ison, l1, l2 : Byte; sec : Byte);
      Procedure   Run; Virtual;
      Function    GetDevice(uType : Byte; Sec : Byte) : PDevice;
      Function    ExistSector(sec : Byte) : Boolean;
      Destructor  Done;
   End;

implementation

Constructor OSector.Init;
Begin
   Super.Init;
   Size     := 0;
   First    := nil;
   Point    := First;
   Last     := nil;
End;

Function OSector.ExistSector(sec : Byte) : Boolean;

Var Exist : Boolean;

Begin
   Exist := False;
   Point := First;
   While ((Not Exist) and (Point <> Nil)) Do
   Begin
      Exist := Point^.Code = sec;
      Point := Point^.Next;
   End;
   ExistSector := Exist;
End;

Procedure OSector.CommandVoice(sec : Byte; cmd : String);

Var Exist : Boolean;

Begin
   Exist := False;
   Point := First;
   While ((Not Exist) and (Point <> Nil)) Do
   Begin
      Exist := (Point^.Code = sec) and (Point^.UnitType = UNIT_VOICE);
      If (Exist) Then Point^.Dev^.SetComand(cmd);
      Point := Point^.Next;
   End;
End;

Procedure OSector.SetDevice(uType: Byte; ison, l1, l2 : Byte; sec : Byte);
Begin
   Point := First;
   While (Point <> Nil) Do
   Begin
      If ((uType = ALL) or (uType = Point^.UnitType)) Then
      Begin
         If ((sec = ALL) or (sec = Point^.Code)) Then
         Begin
            If (ison <> Point^.Dev^.On) Then Point^.Dev^.SetOn(Boolean(ison));
            if (l1 <> ALL) Then Point^.Dev^.SetLevel1(l1);
            if (l2 <> ALL) Then Point^.Dev^.SetLevel2(l2);
         End;
      End;
      Point := Point^.Next;
   End;
End;

Function OSector.GetDevice(uType : Byte; Sec : Byte) : PDevice;

Var
   dev   : PDevice;
   found : Boolean;

Begin
   dev   := Nil;
   found := False;
   Point := First;
   While ((Point <> Nil) and (Not Found)) Do
   Begin
      If ((uType = Point^.UnitType) and (Sec = Point^.Code)) Then
      Begin
         dev   := Point^.Dev;
         found := True;
      End;
      Point := Point^.Next;
   End;
   GetDevice := Dev;
End;

Procedure OSector.InsertItem(item : PElementSector);

Var
  Prev  : PElementSector;
  Vazio : Boolean;

Begin
   Prev := Nil;
   If (item <> Nil) Then
   Begin
      Inc(Size);
      Vazio := True;
      Point := First;
      While (Point <> Nil) Do
      Begin
         Prev  := Point;
         Point := Point^.Next;
         Vazio := False;
      End;
      Point := item;
      Point^.Next := Nil;
      If (Not Vazio) Then Prev^.Next := Point
      Else First  := Point;
   End;
End;

Procedure OSector.InsertAgent(sec, uType : Byte; dev : PDevice);

Var
   agSensor  : PSensor;
   agWindow  : PWindow;
   agLight   : PLight;
   agSample  : PSample;
   agExtract : PExtractor;
   agTv      : PTv;
   agVideo   : PVideo;
   agAirCond : PAirConditionning;
   agVent    : PVentilator;
   agStrove  : PStrove;
   agShowwer : PShowwer;
   agsmpTime : PAgSTime;
   ms        : PMicroServer;

Begin
   ms := Super.GetMicroServer(sec);
   If (ms <> Nil) Then
   Begin
      Case (uType) of
         1..6 : Begin
                  New(agSensor, Init(sec, uType, ms^.Size+1, dev));
                  Super.AddAgent(sec, agSensor);
               End;
         50, 51 : Begin
                  New(agWindow, Init(sec, uType, ms^.Size+1, dev));
                  Super.AddAgent(sec, agWindow);
               End;
         66 : Begin
                  New(agShowwer, Init(sec, uType, ms^.Size+1, dev));
                  Super.AddAgent(sec, agShowwer);
               End;
         54, 56, 63, 68 : Begin
                  New(agSample, Init(sec, uType, ms^.Size+1, dev));
                  Super.AddAgent(sec, agSample);
               End;
         58, 62 : Begin
                  New(agTv, Init(sec, uType, ms^.Size+1, dev));
                  Super.AddAgent(sec, agTv);
               End;
         59..61 : Begin
                  New(agVideo, Init(sec, uType, ms^.Size+1, dev));
                  Super.AddAgent(sec, agVideo);
               End;
         55, 67 : Begin
                  New(agsmpTime, Init(sec, uType, ms^.Size+1, dev));
                  Super.AddAgent(sec, agsmpTime);
               End;
         64 : Begin
                  New(agAirCond, Init(sec, uType, ms^.Size+1, dev));
                  Super.AddAgent(sec, agAirCond);
               End;
         53 : Begin
                  New(agStrove, Init(sec, uType, ms^.Size+1, dev));
                  Super.AddAgent(sec, agStrove);
               End;
         65 : Begin
                  New(agVent, Init(sec, uType, ms^.Size+1, dev));
                  Super.AddAgent(sec, agVent);
               End;
         52 : Begin
                  New(agLight, Init(sec, uType, ms^.Size+1, dev));
                  Super.AddAgent(sec, agLight);
               End;
         57 : Begin
                  New(agExtract, Init(sec, uType, ms^.Size+1, dev));
                  Super.AddAgent(sec, agExtract);
               End;
      End;
   End;
End;

Procedure OSector.Add(sec : Byte; uType : Byte; dev : PDevice);

Var
   item  : PElementSector;
   mydev : PDevice;
   i     : Byte;
   ms    : PMicroServer;

Begin
   { If not exist this sector, then create all sensors from it }
   If (Not ExistSector(sec)) Then
   Begin
      New(ms, Init);
      ms^.Id := sec;
      Super.Add(ms);
      { Initialize all sensors }
      For i := 1 To 6 Do
      Begin
         New(item);
         item^.Code := sec;
         item^.UnitType := i;
         New(mydev, Init);
         item^.Dev := mydev;
         InsertItem(item);
         InsertAgent(sec, i, mydev);
      End;
   End;
   If (uType <> UNIT_VOID) Then
   Begin
      New(item);
      item^.Code     := sec;
      item^.UnitType := uType;
      item^.Dev      := dev;
      InsertItem(item);
      InsertAgent(sec, uType, dev);
   End;
End;

Procedure OSector.Run;
Begin
   Super.Run;
End;

Destructor OSector.Done;
Begin
   Point := First;
   While (Point <> Nil) Do
   Begin
      Point := Point^.Next;
      If (First.Dev <> Nil) Then
         Dispose(First.Dev, Done);
      Dispose(First);
      First := Point;
   End;
   Super.Done;
End;

end.
