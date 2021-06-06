UNIT DrPixels;


INTERFACE

USES
   Objects, MyMouse, Graph, Config;

TYPE

   PDrawPixel = ^ODrawPixel;
   ODrawPixel = Object (TObject)
      Value     : Byte;
      NewColor  : Byte;
      Pressed   : Boolean;
      Select    : Boolean;

      Constructor Init(ix, iy, w, h : Integer; v : Byte; M : PMouse);
      Procedure   SetBorder(on : Boolean);
      Procedure   SetNewColor(c : Byte);
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Procedure   Run; Virtual;
      Procedure   Clear; Virtual;
      Function    Selected : Boolean;
      Destructor  Done;
   End;

IMPLEMENTATION

Constructor ODrawPixel.Init(ix, iy, w, h : Integer; V : Byte; M : PMouse);

Begin
   TObject.Init(ix, iy, w, h, M);
   Value     := v;
   NewColor  := 0;
   Border    := 0;
   Pressed   := False;
End;

Procedure ODrawPixel.SetBorder(on : Boolean);
Begin
   If (on) Then Border := COLOR_BORDER
   Else Border := Value;
End;

Procedure ODrawPixel.Draw;

Var
   ty : Integer;

Begin
   SetColor(Border);
   Line(x, y, x+Width, y);
   Line(x, y+Height, x+Width, y+Height);
   Line(x, y+1, x, y+Height-1);
   Line(x+Width, y+1, x+Width, y+Height-1);

   SetColor(Value);
   For ty := y+1 To y+Height-1 Do
      Line(x+1, ty, x+Width-1, ty);
End;

Procedure ODrawPixel.Show;
Begin
   TObject.Show;
End;

Procedure ODrawPixel.Clear;
Begin
   Value := 0;
   Draw;
End;


Procedure ODrawPixel.Run;
Begin
   If (Visible) Then Show;

   If (InRange) Then
   Begin
      If (Pointer^.Press) Then
      Begin
         If (Not Pressed) Then
         Begin
            Pressed := True;
            Value   := NewColor;
            Select  := True;
            Pointer^.Show(False);
            Draw;
            Pointer^.Show(True);
         End;
      End Else Pressed := False;
   End Else Pressed := False;
End;

Procedure ODrawPixel.SetNewColor(c : Byte);
Begin
   NewColor := c;
End;

Function ODrawPixel.Selected : Boolean;

Begin
   Selected := Select;
   Select   := False;
End;


Destructor ODrawPixel.Done;

Begin
   TObject.Done;
End;

End.
