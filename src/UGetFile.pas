UNIT UGetFile;


INTERFACE

Uses
   Graph, Crt, MyMouse, Button, Rolls,
   Boxs, TextBoxs, RollBoxs, Objects,
   Labels, Config, SysUtils;

TYPE
   PGetFile = ^OGetFile;
   OGetFile = Object (OBox)
      FileName : Str12;
      RollFile : ORollBox;
      btclick  : TypeButtons;
      Title    : String;
      btOk     : OButton;
      btCancel : OButton;

      Constructor Init(ix, iy, h : Integer; tit, T : String; M : PMouse);
      Procedure   Run; Virtual;
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Destructor  Done;
   End;

IMPLEMENTATION

Constructor OGetFile.Init(ix, iy, h : Integer; tit, T : String; M : PMouse);

Var
   i : Integer;
   DirInfo : TSearchRec;

Begin
   btclick := NONE;
   Title   := tit;
   OBox.Init(ix, iy, 27+(20*8), 65+(h*15), True, Title, True, M);
   RollFile.Init(x+5, y+20, 19, h, T, M);

   if (FindFirst(T, faAnyFile, DirInfo) = 0) Then
   Begin
      Repeat
         RollFile.Add(DirInfo.Name);
      until FindNext(DirInfo) <> 0;
      FindClose(DirInfo);
   End;

   i := (Width-140) Div 3;
   btOk.Init    (x+i,        y+Height-20, 70, 15, 'Confirma', M);
   btCancel.Init(x+(i*2)+70, y+Height-20, 70, 15, 'Cancela', M);

   OBox.Draw;
   RollFile.Draw;
   btOk.Draw;
   btCancel.Draw;
End;

Procedure OGetFile.Run;
Begin
   Repeat
      OBox.Run;
      RollFile.Run;
      btOk.Run;
      btCancel.Run;
      ScreenShow;
      If (RollFile.Selected) Then
      Begin
         FileName := RollFile.TextSelect;
         RollFile.Text := FileName;
         RollFile.Draw;
      End;
      If (btOk.Selected) Then btClick := OK;
      If (btCancel.Selected) Then btClick := CANCEL;
   Until (btClick <> NONE);
End;

Procedure OGetFile.Show;
Begin
   OBox.Show;
End;

Procedure OGetFile.Draw;
Begin
   OBox.Draw;
End;

Destructor OGetFile.Done;
Begin
   btCancel.Done;
   btOk.Done;
   RollFile.Done;
   OBox.Done;
End;

End.
