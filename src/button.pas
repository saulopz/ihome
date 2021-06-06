UNIT Button;


INTERFACE

USES
   Objects, MyMouse, Graph, Config;

TYPE
   TypeButtons = (NONE, OK, CANCEL);

   PButton = ^OButton;
   OButton = Object (TObject)
      Text      : String;
      Code      : Byte;
      Select    : Boolean;
      Pressed   : Boolean;
      btClick   : TypeButtons;

      Constructor Init(ix, iy, w, h : Integer; Tx : String; M : PMouse);
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Procedure   Run; Virtual;
      Function    Selected : Boolean;
      Destructor  Done;
   End;

IMPLEMENTATION

Constructor OButton.Init(ix, iy, w, h : Integer; Tx : String; M : PMouse);

Begin
   TObject.Init(ix, iy, w, h, M);
   Text      := Tx;
   Align     := CENTER;
   btClick   := NONE;
   Visible   := True;
   Select    := False;
   Pressed   := False;
   Code      := 0;
End;

Procedure OButton.Draw;

Var
   tx, ty : Integer;
   size   : Integer;
   txaux  : String;

Begin
   Pointer^.Show(False);
   SetColor(Border);
   Line(x, y, x+Width, y);
   Line(x, y+Height, x+Width, y+Height);
   Line(x, y+1, x, y+Height-1);
   Line(x+Width, y+1, x+Width, y+Height-1);

   If (InRange and Active) Then SetColor(Backon)
   Else SetColor(Backoff);

   For ty := y+1 To y+Height-1 Do
      Line(x+1, ty, x+Width-1, ty);

   ty    := y + (((y+Height - y) div 2) - 3);

   If (Active) Then SetColor(TxColor)
   Else SetColor(Border);

   If (Length(Text)*8 > Width-2) Then
      txaux := Copy(Text, 1, ((Width-2) Div 8))
   Else txaux := Text;

   Size := Length(txaux);

   Case (Align) of
      LEFT   : tx := x + 2;
      RIGHT  : tx := (x+Width - 2) - Size*8;
      CENTER : tx := x + ((x+Width - x) Div 2) - ((Size*8) Div 2);
      Else tx := x + 2;
   End;

   OutTextXY(tx, ty, Txaux);
   Pointer^.Show(True);
End;

Procedure OButton.Show;
Begin
   TObject.Show;
End;


Procedure OButton.Run;
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

Function OButton.Selected : Boolean;

Begin
   Selected := Select;
   Select   := False;
End;

Destructor OButton.Done;

Begin
   TObject.Done;
End;

End.
