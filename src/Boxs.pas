UNIT Boxs;


INTERFACE

USES
   Objects, MyMouse, Graph, Button, Config;

TYPE
   PBox = ^OBox;
   OBox = Object (TObject)
      Text      : String;
      Level     : Integer;
      Transp    : Boolean;
      Header    : Integer;

      Constructor Init(ix, iy, w, h : Integer; t : Boolean; tx : String; Head : Boolean; M : PMouse);
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Procedure   Run; Virtual;
      Procedure   Clear; Virtual;
      Function    Transparency(c : Byte) : Byte;
      Destructor  Done;
   End;

IMPLEMENTATION

Constructor OBox.Init(ix, iy, w, h : Integer; t : Boolean; tx : String; Head : Boolean; M : PMouse);

Var
   i, j : Integer;
   c    : Boolean;

Begin
   TObject.Init(ix, iy, w, h, M);
   Text      := tx;
   Transp    := t;

   If (Head) Then Header := 15
   Else Header := 0;

   c := False;
   Pointer^.Show(False);
   If (Transp) Then
   Begin
      For j := y+Header+1 To y+Height-1 Do
      Begin
         i := x+1+(Byte(c));
         While (i < x+Width) Do
         Begin
            If (c) Then
            Begin
               PutPixel(i, j, Transparency(GetPixel(i, j)));
               i := i+1;
               PutPixel(i, j, 0);
            End
            Else
            Begin
               PutPixel(i, j, Transparency(GetPixel(i, j)));
               i := i+1;
               PutPixel(i, j, 0);
            End;
            i := i+1;
         End;
         c := Not c;
      End;
   End
   Else
   Begin
      SetColor(backgr);
      For i := y+Header+1 To y+Height-1 Do
      Begin
         Line(x+1, i, x+Width-1, i);
      End;
   End;
   Pointer^.Show(True);
End;

Procedure OBox.Draw;

Var
   tx, i : Integer;
   Size  : Integer;

Begin
   If (Not Transp) Then
   Begin
      SetColor(backgr);
      For i := y+Header+1 To y+Height-1 Do
      Begin
         Line(x+1, i, x+Width-1, i);
      End;
   End;

   Pointer^.Show(False);
   SetColor(Border);
   Line(x, y, x+Width, y);
   Line(x, y+Height, x+Width, y+Height);
   Line(x, y+1, x, y+Height-1);
   Line(x+Width, y+1, x+Width, y+Height-1);
   If (Header > 0) Then
      Line(x+1, y+15, x+Width-1, y+15);

   If (InRange) Then SetColor(Backon)
   Else SetColor(Backoff);
   For i := y+1 To y+Header-1 Do
   Begin
      Line(x+1, i, x+Width-1, i);
   End;

   Size := Length(Text);
//   i    := y + (((y+Height - y) div 2) - 3);

   Case (Align) of
      LEFT   : tx := x + 2;
      RIGHT  : tx := (x+Width - 2) - Size*8;
      CENTER : tx := x + ((x+Width - x) Div 2) - ((Size*8) Div 2);
      else tx := x + 2;
   End;

   SetColor(TxColor);

   If (Header>0) Then OutTextXY(tx, y+4, Text);

{
   If (Not Transp) Then
   Begin
      SetColor(0);
      For i := y+16 To y+Height-1 Do
      Begin
         Line(x+1, i, x+Width-1, i);
      End;
   End;
}
   Pointer^.Show(True);
End;

Procedure OBox.Show;

Begin
   TObject.Show;
End;

Procedure OBox.Run;

Begin
   If (Visible) Then Show;
End;


Function OBox.Transparency(c : Byte) : Byte;
Begin
   If ((c= 2) or (c= 3) or (c= 5) or (c= 7) or
       (c=10) or (c=11) or (c=14) or (c=15)) Then
      Transparency := 7
   Else Transparency := 8;
End;

Procedure OBox.Clear;

Var i : Integer;

Begin
   Pointer^.Show(False);
   SetColor(0);
   For i := y To y+Height Do
      Line(x, i, x+Width, i);
   Pointer^.Show(True);
End;

Destructor OBox.Done;

Begin
   TObject.Done;
End;

End.
