UNIT textboxs;


INTERFACE

USES
   Crt, Objects, MyMouse, Graph, Config;

TYPE
   Ptextbox = ^Otextbox;
   Otextbox = Object (TObject)
      Text       : String;
      Limit      : Byte;
      SpecialKey : Char;
      select     : Boolean;

      Constructor Init(ix, iy, w, h : Integer; Tx : String; M : PMouse);
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Procedure   Run; Virtual;
      Procedure   SetText(tx : String);
      Function    Selected : Boolean;
      Destructor  Done;
   End;

IMPLEMENTATION

Constructor Otextbox.Init(ix, iy, w, h : Integer; Tx : String; M : PMouse);

Begin
   TObject.Init(ix, iy, (w*8)+4, h, M);
   Text       := Tx;
   Limit      := w;
   SpecialKey := #0;
   Select     := False;
End;

Procedure Otextbox.Draw;

Var
   ty : Integer;

Begin
   Pointer^.Show(False);
   SetColor(Border);
   Line(x, y, x+Width, y);
   Line(x, y+Height, x+Width, y+Height);
   Line(x, y+1, x, y+Height-1);
   Line(x+Width, y+1, x+Width, y+Height-1);

   If (InRange) Then SetColor(Backon)
   Else SetColor(Backgr);

   For ty := y+1 To y+Height-1 Do
      Line(x+1, ty, x+Width-1, ty);

   ty := y + (((y+Height - y) div 2) - 3);

   SetColor(TxColor);
   OutTextXY(x+2, ty, Text);
   Pointer^.Show(True);
End;

Procedure Otextbox.Show;
Begin
   TObject.Show;
End;


Procedure Otextbox.Run;

Var
   key : Char;

Begin
   If (Visible) Then Show;

   If (InRange) Then
   Begin
      If (KeyPressed) Then
      Begin
         Key := Readkey;
         Case (Key) of
            #8  : If (Length(Text) > 0) Then
                     Text := Copy(Text, 1, Length(Text)-1);
            #13 : Begin
                     SpecialKey := #13;
                     Select := True;
                  End;
            #27 : Begin
                     SpecialKey := #27;
                     Select := True;
                  End;
            Else If (Length(Text) < Limit) Then
               Text := Text+Key;
         End;
         Draw;
      End;
   End Else If (KeyPressed) Then Readkey;
End;

Procedure OTextBox.SetText(tx : String);
Begin
   Text := tx;
   Draw;
End;

Function OTextBox.Selected : Boolean;
Begin
   Selected   := Select;
   Select     := False;
End;


Destructor Otextbox.Done;

Begin
End;

End.
