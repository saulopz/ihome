Program Testbt;

Uses
   Config, Graph, Button, Labels, MyMouse, Crt, RollText;

Var
   bt   : PButton;
   lb   : PLabel;
   P    : PMouse;
   sair : Boolean;
   mx, my, mb : integer;

   MyTest : PRollBox;

Begin
   InitGraph('Testbt', false);

   New(P, Init);
   P^.Show(True);

   New(lb, Init(100, 100, ' Pressione qualquer tecla para continuar...', P));

   lb^.SetText(lb^.GetText);
   lb^.Draw;

   New(MyTest, Init(10, 200, 30, 3, 'Teste de Caixa de texto', P));
   MyTest^.Draw;

   New(bt, Init(100, 150, 100, 15, 'sair', P));
   bt^.Draw;
   ScreenShow;

   Sair := False;
   Repeat
      bt^.Run;
      MyTest^.Run;
      lb^.Run;
      ScreenShow;

      If (MyTest^.Selected) Then
      Begin
         lb^.SetText(MyTest^.TextSelect);
         MyTest^.Draw;
         lb^.Draw
      End;
      If (bt^.Selected) Then Sair := True;
   Until (Sair);

   Dispose(bt, Done);
   Dispose(MyTest, Done);

   Dispose(lb, Done);
   CloseGraph;
End.
