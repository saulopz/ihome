UNIT UEleMap;

INTERFACE

USES
   Graph, MyMouse, Objects, Collects, Icones,
   Config, MapDB, ImgDB, Devices, Agents,
   SystemMS;

TYPE
   PGrid = ^TGrid;
   PElement = ^OElement;
   TGrid = Array[1..MapWIDTH, 1..MapHEIGHT] of PElement;

   OElement = Object (TObject)
      Code     : NameImgSize;
      Step     : 0..1;
      ListIcons: Array[0..5] of PIcon;
      Dev      : PDevice; { Dev^.On ON | OFF}
      MyOn     : Byte;
      MyLevel1 : Byte;
      MyLevel2 : Byte;
      Sector   : Byte;
      MyType   : Byte;
      Course   : SetofCourse;
      Floor    : PIcon;
      icVoid   : PIcon;
      Pressed  : Boolean;
      Select   : Boolean;
      Go       : Boolean;
      Map      : PGrid;
      GoX      : Integer;
      GoY      : Integer;
      MyX      : Integer;
      MyY      : Integer;
      Walking  : Boolean;

      Constructor Init(ix, iy, w, h : Integer; t : Byte; icv : PIcon; M : PMouse);
      Procedure   SetIcon(ic : PIcon; l : Byte);
      Procedure   FreeIcons;
      Procedure   Draw; Virtual;
      Procedure   OverDraw;
      Procedure   Show; Virtual;
      Procedure   Run; Virtual;
      Procedure   SetType(t : Byte);
      Procedure   SetCourse(c : SetofCourse);
      Procedure   SetFloor(ic : PIcon);
      Procedure   SetDevice(d : PDevice);
      Procedure   GoToXY(ix, iy : Integer);
      Procedure   SetMap(m : PGrid);
      Procedure   Complete;
      Procedure   Clear;
      Function    Selected : Boolean;
      Function    ifGo : Boolean;
      Function    GetCode : String;
      Function    Changed : Boolean;
      Procedure   DrawBorder; Virtual;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OElement.Init(ix, iy, w, h : Integer; t : Byte; icv : PIcon; M : PMouse);

Var
   i : Byte;

Begin
   TObject.Init(ix, iy, w, h, M);
   For i := 0 To 5 Do ListIcons[i] := Nil;
   Code     := GetUnitFName(t);
   Dev      := Nil;
   Map      := Nil;
   icVoid   := icv;
   Floor    := icv;
   Step     := 0;
   Pressed  := False;
   Select   := False;
   Go       := False;
   Walking  := False;
   GoX      := 1;
   GoY      := 1;
   MyX      := 1;
   MyY      := 1;
   MyType   := t;
   Course   := CRIGHT;
   MyOn     := 0;
   MyLevel1 := 0;
   MyLevel2 := 0;
End;

Function OElement.GetCode : String;
Begin
   GetCode := Code;
End;

Procedure OElement.SetMap(m : PGrid);
Begin
   Map := m;
End;

Procedure OElement.SetType(t : Byte);
Begin
   MyType := t;
End;

Procedure OElement.SetCourse(c : SetofCourse);
Begin
   Course := c;
End;

Procedure OElement.SetIcon(ic : PIcon; l : Byte);
Begin
   ListIcons[l] := ic;
End;

Procedure OElement.SetDevice(d : PDevice);
Begin
   Dev := d;
End;

Procedure OElement.Clear;
Begin
End;

Procedure OElement.SetFloor(ic : PIcon);
Begin
   Floor    := ic;
End;

Procedure OElement.Show;
Begin
//   TObject.Show;
End;

Procedure OElement.GoToXY(ix, iy : Integer);
Begin
   GoX := ix;
   GoY := iy;
   Go  := True;
End;

Procedure OElement.Draw;

Var
   i    : Byte;
   isOn : Boolean;

Begin
   i    := 0;
   isOn := False;

   Floor^.X := X;
   Floor^.Y := Y {- ELEMENTWIDTH};
   Floor^.Draw;

   // Device is On?
   If (Dev <> Nil) Then isON := Dev.On <> 0;
   If (isOn) Then i := 2;

   { if your course is to right }
   If ((Course = CRIGHTDOWN) or
       (Course = CRIGHTUP)   or
       (Course = CRIGHT))    Then
      i := i+1;

   If (isOn) Then i := i + (step*2);

   If (ListIcons[i] <> Nil) Then
   Begin
      ListIcons[i]^.X := X;
      ListIcons[i]^.Y := Y {- ELEMENTWIDTH};
      ListIcons[i]^.Draw;
   End
   Else Begin
      icVoid^.X := X;
      icVoid^.Y := Y {- ELEMENTWIDTH};
      icVoid^.Draw;
   End;
End;

Procedure OElement.OverDraw;

Var
   i    : Byte;
   isOn : Boolean;

Begin
   i    := 0;
   isOn := False;

   // Device is On?
   If (Dev <> Nil) Then isON := Dev.On <> 0;
   If (isOn) Then i := 2;

   { if your course is to right }
   If ((Course = CRIGHTDOWN) or
       (Course = CRIGHTUP)   or
       (Course = CRIGHT))    Then
      i := i+1;

   If (isOn) Then i := i + (step*2);

   If (ListIcons[i] <> Nil) Then
   Begin
      ListIcons[i]^.X := X;
      ListIcons[i]^.Y := Y {- ELEMENTWIDTH};
      ListIcons[i]^.OverDraw;
   End
   Else Begin
      icVoid^.X := X;
      icVoid^.Y := Y {- ELEMENTWIDTH};
      icVoid^.OverDraw;
   End;
End;

Procedure OElement.Complete;
Begin
   If (ListIcons[0] = Nil) Then ListIcons[0] := icVoid;
   If (ListIcons[1] = Nil) Then ListIcons[1] := ListIcons[0];
   If (ListIcons[2] = Nil) Then ListIcons[2] := ListIcons[0];
   If (ListIcons[3] = Nil) Then ListIcons[3] := ListIcons[1];
   If (ListIcons[4] = Nil) Then ListIcons[4] := ListIcons[2];
   If (ListIcons[5] = Nil) Then ListIcons[5] := ListIcons[3];
End;

Procedure OElement.FreeIcons;

var i : Integer;

Begin
   For i := 0 To 5 Do ListIcons[i] := Nil;
End;

Procedure OElement.DrawBorder;
Begin
End;

Procedure OElement.Run;
Begin
   If (Visible) Then Show;

   If (Active and InRange) Then
   Begin
      If (Pointer^.Press) Then
      Begin
         If (Not Pressed) Then
         Begin
            Pressed := True;
            Select  := True;
         End;
      End Else Pressed := False;
   End Else Pressed := False;
End;

Function OElement.Selected : Boolean;

Begin
   Selected := Select;
   Select   := False;
End;

Function OElement.ifGo : Boolean;
Begin
   ifGo := Go;
   Go   := False;
End;

Function OElement.Changed;

Var Change : Boolean;

Begin
   Change := False;
   If (Dev <> Nil) Then
   Begin
      If ((Dev^.On     <> MyOn)      or
          (Dev^.Level1 <> MyLevel1)  or
          (Dev^.Level2 <> MyLevel2)) Then
      Begin
         Change  := True;
         MyOn     := Dev^.On;
         MyLevel1 := Dev^.Level1;
         MyLevel2 := Dev^.Level2;
      End;
   End;
   Changed := Change;
End;

Destructor OElement.Done;
Begin
   TObject.Done;
End;

End.