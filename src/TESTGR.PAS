PROGRAM TestGr;

Uses
   Graph, Crt, Mouse, Button, Rolls,
   Boxs, TextBoxs, RollBoxs, Objects,
   Labels;

Var
   d, m : Integer;
   Bt,b : PButton;
   R, l : PRoll;
   Point: PMouse;
   Exit : Boolean;
   s    : String;
   bx   : PBox;
   tx   : PTextBox;
   k    : Char;
   Rbx  : PRollBox;
   Lb1  : PLabel;

Begin
   d := Detect;
   InitGraph(d, m, '');

   New(Point, Init);
   New(Lb1,   Init(60, 70, 'Este e um texte de Label', Point));
   New(Bt,    Init(100, 100, 100, 15, 'Sair', Point));
   New(b,     Init(100, 300, 200, 15, '', Point));
   New(R,     Init(300, 100, 15, 100, 15, VERTICAL, Point));
   New(L,     Init(100, 200, 100, 15, 5, HORIZONTAL, Point));
   New(tx,    Init(100, 400, 10, 15, 'Texto', Point));
   New(Rbx,   Init(400, 100, 20, 5, 'Rolagem', Point));

   Rbx^.Align := CENTER;
   Rbx^.Draw;
   Rbx^.Add('Saulo');
   Rbx^.Add('Mauricio');
   Rbx^.Add('Cristiano');
   Rbx^.Add('Lara Popov');
   Rbx^.Add('Cristina Popov Zambiasi');
   Rbx^.Add('Jose Luiz');
   Rbx^.Add('Bagueera');
   Rbx^.Add('Lobinha');

   Lb1^.Draw;
   Bt^.Draw;
   b^.Draw;
   R^.Draw;
   L^.Draw;
   tx^.Draw;
   Rbx^.Draw;

   New(bx,    Init(50, 50, 540, 380, True, 'Teste', Point));
   bx^.Draw;

   Point^.Show(True);
   Str(R^.Level, s);

   b^.Text := s;
   b^.Draw;

   Exit := False;

   Repeat
      bx^.Run;
      Lb1^.Run;
      Bt^.Run;
      R^.Run;
      L^.Run;
      b^.Run;
      if (b^.Selected) Then
      Begin
         b^.Text := '';
         b^.Draw;
      End;
      Rbx^.Run;
      If (Rbx^.Selected) Then
      Begin
         b^.Text := Rbx^.TextSelect;
         b^.Draw;
      End;
      If (R^.Selected) Then
      Begin
         Str(R^.Level, s);
         b^.Text := s;
         b^.Draw;
      End;
      L^.Selected;
      Tx^.Run;
      Exit := (Bt^.Selected);
      If (KeyPressed) Then
      Begin
         k := Readkey;
         Exit := k = #27;
      End;
   Until (Exit);

   Dispose(Rbx,   Done);
   Dispose(Tx,    Done);
   Dispose(Lb1,   Done);
   Dispose(Bx,    Done);
   Dispose(L,     Done);
   Dispose(R,     Done);
   Dispose(b,     Done);
   Dispose(bt,    Done);
   Dispose(Point, Done);

   CloseGraph;
End.
