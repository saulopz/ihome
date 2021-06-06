UNIT Rolls;


INTERFACE

USES
   Objects, MyMouse, Graph, Button, Config;

CONST
   BTNROLLSIZE = 15;


TYPE
   PRoll = ^ORoll;
   ORoll = Object (TObject)
      Size      : Byte;
      Level     : Integer;
      Dir       : Direction;
      Select    : Boolean;
      But1      : OButton;
      But2      : OButton;

      Constructor Init(ix, iy, w, h, S : Integer; d : Direction; M : PMouse);
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Function    Selected : Boolean;
      Procedure   Run; Virtual;
      Destructor  Done;
   End;

IMPLEMENTATION

Constructor ORoll.Init(ix, iy, w, h, S : Integer; d : Direction; M : PMouse);

Begin
   TObject.Init(ix, iy, w, h, M);
   Size      := S;
   Dir       := d;
   Select    := False;
   Level     := 0;

   If (Dir = VERTICAL) Then
   Begin
      But1.Init(X, Y, Width, BTNROLLSIZE, #30, M);
      But2.Init(X, Y+Height-BTNROLLSIZE, Width, BTNROLLSIZE, #31, M);
   End
   Else
   Begin
      But1.Init(X, Y, BTNROLLSIZE, Height, #17, M);
      But2.Init(X+Width-BTNROLLSIZE, Y, BTNROLLSIZE, Height, #16, M);
   End;

   But1.Border  := Border;
   But1.Backoff := Backoff;
   But1.Backon  := Backon;

   But2.Border  := Border;
   But2.Backoff := Backoff;
   But2.Backon  := Backon;
End;

Procedure ORoll.Draw;

Var
   tx, ty, i : Integer;

Begin
   SetColor(Border);
   Line(x, y, x+Width, y);
   Line(x, y+Height, x+Width, y+Height);
   Line(x, y+1, x, y+Height-1);
   Line(x+Width, y+1, x+Width, y+Height-1);

   If (Dir = VERTICAL) Then
   Begin
      SetColor(Backgr);
      For tx := x+1 To x+Width-1 Do
         Line(tx, y+BTNROLLSIZE-1, tx, y+Height-BTNROLLSIZE-1);
      SetColor(Border);
      If (Size < 1) Then ty := y+BTNROLLSIZE
      Else
      Begin
         ty := (height-(BTNROLLSIZE*3))*Level;
         ty := y + BTNROLLSIZE + (ty Div Size);
      End;
      Line(x+1, ty, x+Width-1, ty);
      Line(x+1, ty+BTNROLLSIZE, x+Width-1, ty+BTNROLLSIZE);

      For i := ty+1 To ty+BTNROLLSIZE-1 Do
      Begin
         If (InRange) Then SetColor(Backon)
         Else SetColor(Backoff);
         Line(x+1, i, x+Width-1, i);
      End;
   End
   Else
   Begin
      SetColor(Backgr);
      For ty := y+1 To y+Height-1 Do
         Line(x+BTNROLLSIZE+1, ty, x+Width-BTNROLLSIZE+1, ty);
      SetColor(Border);
      If (Size < 1) Then tx := x + BTNROLLSIZE
      Else
      Begin
         tx := (Width-(BTNROLLSIZE*3))*Level;
         tx := x + BTNROLLSIZE + (tx Div Size);
      End;
      Line(tx, y+1, tx, y+Height-1);
      Line(tx+BTNROLLSIZE, y+1, tx+BTNROLLSIZE, y+Height-1);

      For i := tx+1 To tx+BTNROLLSIZE-1 Do
      Begin
         If (InRange) Then SetColor(Backon)
         Else SetColor(Backoff);
         Line(i, y+1, i, y+Height-1);
      End;
   End;

   But1.Draw;
   But2.Draw;
End;

Procedure ORoll.Show;

Begin
   TObject.Show;
End;

Procedure ORoll.Run;

Begin
   If (Visible) Then
   Begin
      Show;
      But1.Run;
      But2.Run;
   End;

   If (But1.Selected) Then
   Begin
      If (Level > 0) Then
      Begin
         Level := Level-1;
         Pointer^.Show(False);
         Draw;
         Pointer^.Show(True);
      End;
      Select := True;
   End
   Else If (But2.Selected) Then
   Begin
      If (Level < Size) Then
      Begin
         Level := Level+1;
         Pointer^.Show(False);
         Draw;
         Pointer^.Show(True);
      End;
      Select := True;
   End;
End;

Function ORoll.Selected : Boolean;
Begin
   Selected := Select;
   Select   := False;
End;

Destructor ORoll.Done;

Begin
   But1.Done;
   But2.Done;
   TObject.Done;
End;

End.
