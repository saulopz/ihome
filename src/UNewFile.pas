UNIT UNewFile;


INTERFACE

Uses
   Graph, Crt, MyMouse, Button, Rolls,
   Boxs, TextBoxs, RollBoxs, Objects,
   Labels, Config, SysUtils;

TYPE
   PNewFile = ^ONewFile;
   ONewFile = Object (OBox)
      FileName : Str12;
      btclick  : TypeButtons;
      lbFile   : OLabel;
      txFile   : OTextBox;
      btOk     : OButton;
      btCancel : OButton;

      Constructor Init(ix, iy, S : Integer; M : PMouse);
      Procedure   Run; Virtual;
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Destructor  Done;
   End;

IMPLEMENTATION

Constructor ONewFile.Init(ix, iy, S : Integer; M : PMouse);

Var
   i : Integer;

Begin
   btclick := NONE;
   FileName := '';

   OBox.Init(ix, iy, 200, 100, True, 'Novo', True, M);

   lbFile.Init(x+10, y+28, 'Nome:', M);
   txFile.Init(x+60, y+25, S, 15, '', M);

   i := (Width-140) Div 3;
   btOk.Init    (x+i,        y+Height-20, 70, 15, 'Confirma', M);
   btCancel.Init(x+(i*2)+70, y+Height-20, 70, 15, 'Cancela', M);

   OBox.Draw;
   lbFile.Draw;
   txFile.Draw;
   btOk.Draw;
   btCancel.Draw;
End;

Procedure ONewFile.Run;
Begin
   Repeat
      OBox.Run;
      btOk.Run;
      btCancel.Run;
      lbFile.Run;
      txFile.Run;
      ScreenShow;

      If (txFile.Text <> FileName) Then
         If (txFile.Text <> '') Then
            FileName := txFile.Text;
      If (btOk.Selected) Then btClick := OK;
      If (btCancel.Selected) Then btClick := CANCEL;
   Until (btClick <> NONE);
End;

Procedure ONewFile.Show;
Begin
   OBox.Show;
End;

Procedure ONewFile.Draw;
Begin
   OBox.Draw;
End;

Destructor ONewFile.Done;

Var
  i, ix, iy, iw, ih : Integer;

Begin
   ix := X;
   iy := Y;
   iw := Width;
   ih := Height;
   lbFile.Done;
   txFile.Done;
   btCancel.Done;
   btOk.Done;
   OBox.Done;

   Pointer^.Show(False);
   SetColor(0);
   For i := iy To iy+ih Do
      Line(ix, i, ix+iw, i);
   Pointer^.Show(True);
End;

End.
