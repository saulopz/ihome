UNIT Labels;


INTERFACE

USES
   Crt, Objects, MyMouse, Graph, Config;

TYPE
   PLabel = ^OLabel;
   OLabel = Object (TObject)
   Private
      Text      : String;
      oldWidth  : Integer;
      Change    : Boolean;
   Public
      Constructor Init(ix, iy: Integer; Tx : String; M : PMouse);
      Procedure   SetText(tx : String);
      Function    GetText : String;
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Procedure   Run; Virtual;
      Destructor  Done;
   End;

IMPLEMENTATION

Constructor OLabel.Init(ix, iy: Integer; Tx : String; M : PMouse);

Begin
   TObject.Init(ix, iy, (Length(Tx)*8)+4, 10, M);
   Text     := Tx;
   oldWidth := 0;
   Change   := False;
End;

Procedure OLabel.SetText(tx : String);
Begin
   Text     := Tx;
   oldWidth := Width;
   Width    := (Length(Tx)*8)+4;
   Change   := True;
End;

Function OLabel.GetText : String;
Begin
   GetText := Text;
End;

Procedure OLabel.Draw;

Var
   ty : Integer;

Begin
   Pointer^.Show(False);
   if (Change) Then
   Begin
      SetColor(Backgr);
      For ty := y+1 To y+Height-1 Do
         Line(x+1, ty, x+oldWidth-1, ty);
   End;

   ty := y + (((y+Height - y) div 2) - 3);

   SetColor(TxColor);
   OutTextXY(x+2, ty, Text);
   Pointer^.Show(True);
End;

Procedure OLabel.Show;
Begin
   TObject.Show;
End;


Procedure OLabel.Run;
Begin
   If (Visible) Then Show;
End;

Destructor OLabel.Done;

Begin
   TObject.Done;
End;

End.
