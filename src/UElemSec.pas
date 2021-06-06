unit UElemSec;

interface

USES
   MyMouse, Graph, Objects, Config, DrPixels;

TYPE
   PElemSec = ^OElemSec;
   OElemSec = Object (TObject)
      Sector   : Byte;
      isOn     : Boolean;
      Pressed  : Boolean;
      Select   : Boolean;

      Constructor Init(ix, iy, w, h : Integer; sec : Byte; M : PMouse);
      Procedure   Draw; Virtual;
      Procedure   Show; Virtual;
      Procedure   Run; Virtual;
      Procedure   SetSector(sec : Byte);
      Function    Selected : Boolean;
      Function    Transparency(c : Byte) : Byte;
      Destructor  Done;
   End;

implementation

Constructor OElemSec.Init(ix, iy, w, h : Integer; sec : Byte; M : PMouse);

Var
   i, j, z : Integer;

Begin
   TObject.Init(ix, iy, w, h, M);
   Sector   := sec;
   isOn     := False;
   Pressed  := False;
   Select   := False;

   For j := y To y+Height Do
      For i := x To x+Width Do
         PutPixel(i, j, Transparency(GetPixel(i, j)));
   j := y;
   z := 0;
   While (j < y+Height) Do
   Begin
      if (z = 1) Then
      Begin
         z := 0;
         i := x+1;
      End
      Else
      Begin
         z := 1;
         i := x;
      End;
      While (i < x+Width) Do
      Begin
         PutPixel(i, j, 0);
         i := i+2;
      End;
      j := j+1;
   End;
End;

Procedure OElemSec.SetSector(sec : Byte);
Begin
   Sector := sec;
End;

Procedure OElemSec.Show;
Begin
   TObject.Show;
End;

Procedure OElemSec.Draw;

Var
   i, j, z : Integer;
   c       : Byte;

Begin
   If (isOn) Then c := 14
   Else If (Sector > 0) Then c := 7
   Else c := 0;

   j := y;
   z := 0;
   While (j < y+Height) Do
   Begin
      if (z = 1) Then Begin
         z := 0;
         i := x+1;
      End Else Begin
         z := 1;
         i := x;
      End;
      While (i < x+Width) Do
      Begin
         PutPixel(i, j, c);
         i := i+2;
      End;
      j := j+1;
   End;
End;

Procedure OElemSec.Run;
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

Function OElemSec.Selected : Boolean;

Begin
   Selected := Select;
   Select   := False;
End;

Function OElemSec.Transparency(c : Byte) : Byte;
Begin
   If (c = 0) Then Transparency := 0
   Else If ((c=1) or (c=5) or (c=9) or (c=13)) Then
      Transparency := 4
   Else if ((c=2) or (c=6) or (c=10) or (c=14)) Then
      Transparency := 7
   Else Transparency := 8;
End;

Destructor OElemSec.Done;
Begin
   TObject.Done;
End;

end.
