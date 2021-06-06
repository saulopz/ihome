Program TGraph;

Uses
   Graph, Crt;

Var d, m, i : Integer;

Begin
   d := Detect;
   InitGraph(d, m, '');

   For i := 1 To 25 Do
      Line(1, i*16, 640, i*16);
   For i := 1 To 33 Do
      Line(i*16, 1, i*16, 480);

   Readkey;

   CloseGraph;
End.
