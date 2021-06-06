UNIT UMenu;


INTERFACE

Uses
   Graph, Crt, MyMouse, Button, Rolls,
   Boxs, TextBoxs, RollBoxs, Objects,
   Labels, Config, Collects;

TYPE
   PMenu = ^OMenu;
   OMenu = Object (OBox)
      FileName : Str12;
      btList   : OCollection;
      Dir      : Direction;
      btClick  : Byte;
      Select   : Boolean;
      Size     : Integer;

      Constructor Init(ix, iy, S : Integer; D : Direction; Tx : String; H : Boolean; M : PMouse);
      Procedure   Add(index : Byte; SetActive : Boolean; Tx : String);
      Procedure   ActiveItem(index : Byte; SetActive : Boolean);
      Function    Selected : Boolean;
      Procedure   Run; Virtual;
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Destructor  Done;
   End;

IMPLEMENTATION

Constructor OMenu.Init(ix, iy, S : Integer; D : Direction; Tx : String; H : Boolean; M : PMouse);
Begin
   BtClick := 0;
   Select  := False;
   Dir     := D;
   Size    := S;

   If (H) Then Header := 15
   Else Header := 0;

   OBox.Init(ix, iy, 10, Header+10, False, Tx, H, M);
   btList.Init;
End;

Procedure OMenu.Add(index : Byte; SetActive : Boolean; Tx : String);

Var
   bt   : PButton;
   xaux : Integer;
   yaux : Integer;

Begin
   if (Dir = VERTICAL) Then
   Begin
      Width  := Size+20;
      Height := Height+Header+10;
      yaux   := (btList.GetSize+1)*25;
      xaux   := 10;
   End
   Else
   Begin
      Height:= 35+Header;
      Width := Width+Size+10;
      yaux  := Header+10;
      xaux  := 10 + (btList.GetSize)*(Size+10);
   End;
   New(bt, Init(x+xaux, y+yaux, Size, 15, Tx, Pointer));
   bt^.Active := SetActive;
   bt^.Code   := index;
   btList.InsertItem(bt);
End;

Procedure OMenu.ActiveItem(index : Byte; SetActive : Boolean);

Var
   bt        : PButton;
   ExitWhile : Boolean;

Begin
   ExitWhile := False;
   bt := btList.GetFirst;
   While (Not ExitWhile) Do
   Begin
      if (bt <> Nil) Then
      Begin
         if (bt^.Code = index) Then
         Begin
            bt^.Active := SetActive;
            bt^.Draw;
            ExitWhile := True;
         End
      End Else ExitWhile := True;
      bt := btList.GetNext;
   End;
End;

Procedure OMenu.Run;

Var
   i    : Byte;
   bt   : PButton;

Begin
   If (Visible) Then Show;


   If (Active and InRange) Then
   Begin
      OBox.Run;
      For i := 1 To btList.GetSize Do
      Begin
         bt := btList.GetItem(i);
         bt^.Run;
         if (bt^.Selected) Then
         Begin
            btClick := bt^.Code;
            Select  := True;
         End;
      End;
   End;
End;

Function OMenu.Selected : Boolean;
Begin
   Selected := Select;
   Select   := False;
End;

Procedure OMenu.Show;
Begin
   OBox.Show;
   btList.Show;
End;

Procedure OMenu.Draw;
Begin
   OBox.Draw;
   btList.Draw;
End;

Destructor OMenu.Done;
Begin
   btList.Done;
   OBox.Done;
End;

End.
