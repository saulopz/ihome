Unit Crt;

INTERFACE

Uses
   alpgraph, ag_sdl;

Function KeyPressed : Boolean;
Function Readkey : Char;

IMPLEMENTATION

Function KeyPressed : Boolean;
Begin
   KeyPressed := KeyPress;
End;

Function Readkey : Char;
Begin
   Readkey := Rkey;
End;

End.