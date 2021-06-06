UNIT UELEMAPX;

INTERFACE

USES
   Graph, MyMouse, Objects, Collects, Icones,
   Config, MapDB, ImgDB, Devices, Agents,
   UElemap, SystemMS, UMapObj;

TYPE
   PElementX = ^OElementX;
   OElementX = Object (OElement)
      Constructor Init(ix, iy, w, h : Integer; t : Byte; icv : PIcon; M : PMouse);
      Procedure   Draw; Virtual;
      Procedure   DrawBorder; Virtual;
      Procedure   Show; Virtual;
      Procedure   Run; Virtual;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OElementX.Init(ix, iy, w, h : Integer; t : Byte; icv : PIcon; M : PMouse);
Begin
   OElement.Init(ix, iy, w, h, t, icv, M);
   Map := Nil;
End;

Procedure OElementX.Show;
Begin
   OElement.Show;
End;

Procedure OElementX.DrawBorder;
Begin
   SetColor(15);
   Line(X, Y+16, X+Width-1, Y+16);
   Line(X, Y+Height+15, X+Width-1, Y+Height+15);
   Line(X, Y+16, X, Y+Height+15);
   Line(X+Width-1, Y+16, X+Width-1, Y+Height+15);
End;

Procedure OElementX.Draw;

Var
   i    : Byte;
   isOn : Boolean;

Begin
   i    := 0;
   Floor^.X := X;
   Floor^.Y := Y {- ElementXWIDTH};
   Floor^.Draw;

   If (Code <> GetUnitFName(UNIT_FLOOR)) Then
   Begin
      // Device is On?
      If (Dev <> Nil) Then
         isON := Dev.On <> 0
      Else isOn := False;
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
         ListIcons[i]^.Y := Y {- ElementXWIDTH};
         ListIcons[i]^.Draw;
      End
      Else Begin
         icVoid^.X := X;
         icVoid^.Y := Y {- ElementXWIDTH};
         icVoid^.Draw;
      End;
   End;
   If (Step = 1) Then Step := 0
   Else Step := 1;
End;

Procedure OElementX.Run;

Var  bx, by, bb : Integer;

Begin
   If (Visible) Then Show;

   If (Active and InRange) Then
   Begin
      If (Pointer^.Press) Then
      Begin
         Pointer^.Status(bx, by, bb);
         If (Not Pressed) Then
            If (bb = 4) Then
            Begin
               Pressed := True;
               Select  := True;
            End Else Begin
               go := True;
            End;
      End Else Pressed := False;
   End Else Pressed := False;
End;

Destructor OElementX.Done;
Begin
   TObject.Done;
End;

End.