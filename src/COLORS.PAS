PROGRAM TestGr;

Uses
   Graph, Crt, Mouse, Button, Rolls;

Var
   d, m, i, j : Integer;

Begin
   d := Detect;
   InitGraph(d, m, '');

   For i := 1 To 160 Do Begin
      SetColor((i-1) Div 10);
      Line(1, i, 640, i);
   End;

   Readkey;

   CloseGraph;
End.
