UNIT Udialog;


INTERFACE

Uses
   Graph, Crt, MyMouse, Button, Rolls,
   Boxs, TextBoxs, RollBoxs, Objects,
   Labels, Config, Strs, Collects, SysUtils;

TYPE
   Pdialog = ^Odialog;
   Odialog = Object (OBox)
      btList   : OCollection;
      StrList  : OStr;
      btClick  : TypeButtons;

      Constructor Init(ix, iy, w, h : Integer; T : Boolean; tx : String; Head : Boolean; M : PMouse);
      Procedure   AddLine(tx : String);
      Procedure   AddButton(w, h : Integer; Tx : String; t : TypeButtons);
      Procedure   Run; Virtual;
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Procedure   Clear; Virtual;
      Destructor  Done;
   End;

IMPLEMENTATION

Constructor Odialog.Init(ix, iy, w, h : Integer; T : Boolean; tx : String; Head : Boolean; M : PMouse);

Var
   i, Yaux : Integer;

Begin
   btClick := NONE;

   OBox.Init(ix, iy, w, h, T, tx, Head, M);
   btList.Init;
   StrList.Init;

   Yaux := 25;
   For i := 1 To StrList.GetSize Do
   Begin
      OutTextXY(X+10, Yaux, StrList.Get(i));
      Yaux := Yaux + 15;
   End;
End;

Procedure ODialog.AddButton(w, h : Integer; Tx : String; t : TypeButtons);
Var
   aux   : Integer;
   i     : Integer;
   size  : Integer;
   btaux : PButton;

Begin
   New(btaux, Init(X, Y, w, h, Tx, Pointer));
   btaux^.btClick := t;
   btList.InsertItem(btaux);

   Size := btList.GetSize;
   aux := (Width-(w*Size)) Div (Size+1);

   For i := 1 To Size Do
   Begin
      btaux    := btList.GetItem(i);
      btaux^.X := X+(aux*i)+(w*(i-1));
      btaux^.Y := Y+Height-20;
   End;
End;

Procedure Odialog.AddLine(tx : String);
Begin
   StrList.Add(tx);
End;

Procedure Odialog.Run;

Var
   ExitRepeat  : Boolean;
   i           : Integer;
   btaux       : PButton;

Begin
   ExitRepeat := False;
   Repeat
      OBox.Run;
      ScreenShow;
      For i := 1 To btList.GetSize Do
      Begin
         btaux := btList.GetItem(i);
         btaux^.Run;
         If (btaux^.Selected) Then
         Begin
            btClick := btaux^.btClick;
            ExitRepeat := True;
         End;
      End;
   Until (ExitRepeat);
End;

Procedure Odialog.Show;
Begin
   OBox.Show;
End;

Procedure Odialog.Draw;

Var
   i, Yaux : Integer;

Begin
   OBox.Draw;
   btList.Draw;
   Pointer^.Show(False);
   Yaux := 25;
   SetColor(txcolor);
   For i := 1 To StrList.GetSize Do
   Begin
      OutTextXY(X+10, Y+Yaux, StrList.Get(i));
      Yaux := Yaux + 15;
   End;
   Pointer^.Show(True);
End;

Procedure ODialog.Clear;
Begin
   OBox.Clear;
End;

Destructor Odialog.Done;
Begin
   btList.Done;
   StrList.Done;
   OBox.Done;
End;

End.
