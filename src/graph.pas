Unit graph;

INTERFACE

Uses
   chars, alpgraph, ag_sdl;

Var
   graph_color   : Byte;
   graph_bkcolor : Byte;

Procedure InitGraph(WindowName : String; f : boolean);
Procedure PutPixel(x, y, c : Integer);
Function  GetPixel(x, y : Integer) : Byte;
Procedure Line(x1, y1, x2, y2 : Integer);
Procedure SetColor(c : Byte);
Procedure SetBkColor(c : Byte);
Procedure ClearDevice;
Procedure OutTextXY(x, y : Integer; Tx : String);
Procedure ScreenShow;
Procedure CloseGraph;

IMPLEMENTATION

Procedure InitGraph(WindowName : String; f : Boolean);
Begin
   AGInit(640,480,8,WindowName, f, false);
End;

Procedure PutPixel(x, y, c : Integer);
Begin
   alpgraph.PutPixel(screen, x, y, c);
End;

Function GetPixel(x, y : Integer) : Byte;
Begin
   GetPixel := Byte(alpgraph.GetPixel(screen, x, y));
End;

Procedure Line(x1, y1, x2, y2 : Integer);
Begin
   DrawLine(screen, x1, y1, x2, y2, graph_color);
End;

Procedure SetColor(c : Byte);
Begin
   graph_color := c;
End;

Procedure SetBkColor(c : Byte);
Begin
   graph_bkcolor := c;
End;

Procedure ClearDevice;
Begin
   DrawFilledRectangle(screen, 0, 0, 640, 480, 0);
End;

Procedure OutTextXY(x, y : Integer; Tx : String);
Begin
   DrawStr(screen, (@charset8x8)^, x, y, Tx, graph_color,
           graph_bkcolor, false, 8, 8);
End;

Procedure ScreenShow;
Begin
   Update(0,0,0,0);
End;

Procedure CloseGraph;
Begin
   AGDone;
End;

Begin
   graph_color   := 0;
   graph_bkcolor := 0;
End.
