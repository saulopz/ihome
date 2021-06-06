Unit USecEdit;

INTERFACE

USES
   MyMouse, Graph, MapDB, ImgDB, Objects, Icones,
   Collects, Config, UElemSec, Boxs;

CONST
   SPRITEWIDTH  = 16;
   MAPWIDTH     = 30;
   MAPHEIGHT    = 20;

TYPE
   PSecEdit = ^OSecEdit;
   OSecEdit = Object (OBox)
      Grid   : Array[1..MAPWIDTH, 1..MAPHEIGHT] of OElemSec;
      Sector : Byte;
      Select : Boolean;
      Constructor Init(ix, iy : Integer; M : PMouse);
      Procedure   Run;  Virtual;
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Procedure   DrawGrid;
      Function    Selected : Boolean;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OSecEdit.Init(ix, iy : Integer; M : PMouse);

Var
   i, j    : Integer;

Begin
   TObject.Init(ix, iy, (MAPWIDTH*SPRITEWIDTH)+2, MAPHEIGHT*SPRITEWIDTH, M);
   Sector := 0;
   Select := False;
   For j := 1 To MAPHEIGHT Do
      For i := 1 To MAPWIDTH Do
         Grid[i,j].Init(X+((i-1)*SPRITEWIDTH), Y+((j-1)*SPRITEWIDTH), 16, 16, Sector, Pointer);
End;

Procedure OSecEdit.Draw;

Var i, j : Integer;

Begin
   SetColor(Border);
   Line(x, y, x+Width, y);
   Line(x, y+Height, x+Width, y+Height);
   Line(x, y, x, y+Height);
   Line(x+Width, y, x+Width, y+Height);

   For j := 1 To MAPHEIGHT Do
      For i := 1 To MAPWIDTH Do
      Begin
         Grid[i,j].isOn := (Sector = Grid[i,j].Sector) and (Sector <> 0);
         Grid[i,j].Draw;
      End;
   DrawGrid;
End;

Procedure OSecEdit.DrawGrid;

Var i : Integer;

Begin
   SetColor(0);
   For i := 1 To MAPWIDTH Do
      Line(x+(i*SPRITEWIDTH), y+1, x+(i*SPRITEWIDTH), y+Height-1);
   For i := 1 To MAPHEIGHT Do
      Line(x+1, y+(i*SPRITEWIDTH), x+Width-1, y+(i*SPRITEWIDTH))
End;

Procedure OSecEdit.Show;
Begin
   TObject.Show;
End;

Procedure OSecEdit.Run;

Var
   i, j   : Integer;

Begin
   For j := 1 To MAPHEIGHT Do
   Begin
      For i := 1 To MAPWIDTH Do
      Begin
         Grid[i, j].Run;
         If (Grid[i, j].Selected) Then
         Begin
            Grid[i,j].Sector := Sector;
            Grid[i,j].isOn := (Sector = Grid[i,j].Sector) and (Sector <> 0);
            Grid[i,j].Draw;
            Select := True;
         End;
      End;
   End;
End;

Function OSecEdit.Selected;
Begin
   Selected := Select;
   Select   := False;
End;

Destructor OSecEdit.Done;

Var
  i, j : Integer;

Begin
   For j := 1 To MAPHEIGHT Do
      For i := 1 To MAPWIDTH Do
         Grid[i, j].Done;
   TObject.Done;
End;

End.