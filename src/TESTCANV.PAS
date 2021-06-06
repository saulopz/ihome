PROGRAM TestGr;

Uses
   Graph, Crt, Mouse, Button, Rolls,
   Boxs, TextBoxs, RollBoxs, Objects,
   Labels, Canvas, DrPixels, Pixels,
   Icones;

Var
   d, m   : Integer;
   i, j   : Integer;
   Exit   : Boolean;
   key    : Char;
   Color  : Byte;
   Code   : Integer;
   istr   : String;

   Point  : PMouse;
   Colors : PRollBox;
   btSair : PButton;
   Canv   : PCanvas;
   Fig    : PIcon;

Begin
   d := Detect;
   InitGraph(d, m, '');

   New(Point,  Init);
   New(Colors, Init(10,  10, 10, 16, 'Cores', Point));
   New(Canv,   Init(200, 10, 20, 40, 10, 'Desenho', Point));
   New(Fig,    Init(500, 10, 20, 40, Point));
   New(btSair, Init(200,450, 50, 15, 'Sair', Point));

   Colors^.Align := CENTER;
   For i := 0 To 15 Do
   Begin
      Str(i, istr);
      Colors^.Add(istr);
   End;
   Colors^.Draw;
   Canv^.Draw;
   Fig^.Draw;
   btSair^.Draw;

   Point^.Show(True);
   Exit := False;

   Repeat
      Colors^.Run;
      Canv^.Run;
      btSair^.Run;

      If(Colors^.Selected) Then
      Begin
         Val(Colors^.TextSelect, Color, Code);
         If (Code = 0) then
            Canv^.SetCanvasColor(Color);
      End;

      If(Canv^.Selected) Then
      Begin
         For j := 1 To Fig^.Height Do
            For i := 1 To Fig^.Width Do
               Fig^.SetPixelColor(i, j, Canv^.GetPixelColor(i, j));
      End;

      Exit := (btSair^.Selected);
      If (KeyPressed) Then
      Begin
         Key := Readkey;
         Exit := Key = #27;
      End;
   Until (Exit);

   Dispose(btSair, Done);
   Dispose(Fig,    Done);
   Dispose(Canv,   Done);
   Dispose(Colors, Done);
   Dispose(Point , Done);

   CloseGraph;
End.
