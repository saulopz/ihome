UNIT RollBoxs;


INTERFACE

USES
   Objects, MyMouse, Graph, Collects, Rolls, Strs, Button, Config;

TYPE
   PRollBox = ^ORollBox;
   ORollBox = Object (TObject)
      Text        : String;
      Select      : Boolean;
      TextSelect  : String;
      SizeWidth   : Byte;
      SizeHeight  : Byte;
      Position    : Byte;
      Bt          : OCollection;
      txcollect   : OStr;
      Roll        : ORoll;
      Reconstruct : Boolean;
      Size        : Integer;

      Constructor Init(ix, iy, w, h : Integer; Tx : String; M : PMouse);
      Procedure   Add(tx : String);
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Procedure   Run; Virtual;
      Procedure   Free; Virtual;
      Procedure   SetPos(i : Integer);
      Function    GetPos : Integer;
      Function    Selected : Boolean;
      Destructor  Done;
   End;

IMPLEMENTATION

Constructor ORollBox.Init(ix, iy, w, h : Integer; Tx : String; M : PMouse);

Begin
   SizeWidth := w;
   SizeHeight:= h;
   Position  := 1;

   TObject.Init(ix, iy, (w*8)+25, (h*15)+15+2, M);

   Text      := Tx;
   Select    := False;
   TextSelect:= '';
   Size      := 0;

   Reconstruct := True;

   Roll.Init(x+(w*8)+10, y+15, 15, Height-15, 0, VERTICAL, M);
   Bt.Init;
   TxCollect.Init;
End;

Procedure ORollBox.SetPos(i : Integer);
Begin
   If (i <= Size) Then Position := i
   Else Position := Size;
   Roll.Level := Position;
End;

Function ORollBox.GetPos : Integer;
Begin
   GetPos := Position;
End;


Procedure ORollBox.Add(tx : String);

Begin
   Size := Size + 1;
   TxCollect.Add(tx);
   If (TxCollect.GetSize > SizeHeight) Then
      Roll.Size := Roll.Size+1;
   Reconstruct := True;
End;

Procedure ORollBox.Draw;

Var
   tx, i : Integer;
   txaux : String;
   j     : Integer;
   btaux : PButton;

Begin
   Pointer^.Show(False);
   SetColor(Border);
   Line(x, y, x+Width, y);
   Line(x, y+Height, x+Width, y+Height);
   Line(x, y+1, x, y+Height-1);
   Line(x+Width, y+1, x+Width, y+Height-1);
   Line(x+1, y+15, x+Width-1, y+15);

   If (InRange) Then SetColor(Backon)
   Else SetColor(Backoff);

   For i := y+1 To y+14 Do
      Line(x+1, i, x+Width-1, i);

   SetColor(Backgr);
   For i := y+16 To y+Height-1 Do
      Line(x+1, i, x+Width-1, i);

   j := Length(Text);
   // i := y + (((y+Height - y) div 2) - 3);

   Case (Align) of
      LEFT   : tx := x + 2;
      RIGHT  : tx := (x+Width - 2) - j*8;
      CENTER : tx := x + ((x+Width - x) Div 2) - ((j*8) Div 2);
      else tx := x + 2;
   End;

   SetColor(TxColor);

   OutTextXY(tx, y+4, Text);

   Roll.Draw;

   If (Reconstruct) Then
   Begin
      Bt.Free;
      For i := 1 To SizeHeight Do
      Begin
         txaux := txcollect.Get(Position+i-1);
         If (txaux <> 'NULL') Then
         Begin
            New(btaux, Init(x+1, y+(i*15)+1, Width-17, 15, txaux, Pointer));
            btaux^.Align  := LEFT;
            btaux^.Border := Backgr;
            btaux^.Backoff:= Backgr;
            Bt.InsertItem(btaux);
         End;
      End;
      Reconstruct := False;
   End;

   Bt.Draw;
   Pointer^.Show(True);
End;

Procedure ORollBox.Show;
Begin
   TObject.Show;
End;


Procedure ORollBox.Run;

Var
   i     : Integer;
   btaux : PButton;

Begin
   If (Visible) Then Show;

   If (InRange) Then
   Begin
      Roll.Run;
      If (Roll.Selected) Then
      Begin
         If (Position <> Roll.Level+1) Then
         Begin
            Position := Roll.Level+1;
            Reconstruct := True;
            Draw;
         End;
      End;
      If (Bt.GetSize > 0) Then
      Begin
         For i := 1 To Bt.GetSize Do
         Begin
            btaux := Bt.GetItem(i);
            btaux^.Run;
            if (btaux^.Selected) Then
            Begin
               Select     := True;
               TextSelect := btaux^.Text;
            End;
         End;
      End;
   End;
End;

Function ORollBox.Selected : Boolean;

Begin
   Selected   := Select;
   Select     := False;
End;

Procedure ORollBox.Free;
Begin
   Position   := 1;
   Size       := 0;
   Roll.Size  := 0;
   Roll.Level := 0;
   bt.Free;
   txCollect.Free;
   Reconstruct := True;
End;

Destructor ORollBox.Done;

Begin
   Roll.Done;
   TxCollect.Done;
   Bt.Done;
   TObject.Done;
End;

End.
