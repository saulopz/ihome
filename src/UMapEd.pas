UNIT Umaped;

INTERFACE

USES
   MyMouse, Graph, MapDB, ImgDB, Objects, Icones,
   Collects, MemIcons, UEleMap, Config, UMap;

CONST
   SPRITEWIDTH  = 16;
   SPRITEHEIGHT = 32;

TYPE
   SectorsMatrix = Array[1..MAPWIDTH, 1..MAPHEIGHT] of Byte;

   PMapEd = ^OMapEd;
   OMapEd = Object (OMap)
      SelectedCode    : String;
      SelectedElement : Byte;
      SelectedCourse  : SetofCourse;

      Constructor Init(ix, iy : Integer; iFile: String; M : PMouse);
      Procedure   SelectElement(i : Byte);
      Procedure   Run;  Virtual;
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OMapEd.Init(ix, iy : Integer; iFile: String; M : PMouse);
Begin
   OMap.Init(ix, iy, iFile, M);
   SelectedCode    := 'WALL'; // Codigo da imagem no banco de dados de imagem
   SelectedElement := UNIT_WALL;
   SelectedCourse  := CRIGHT;
End;

Procedure OMapEd.Draw;
Begin
   OMap.Draw
End;

Procedure OMapEd.SelectElement(i : Byte);
Begin
   SelectedElement := i;
   SelectedCode := Map.Element[i];
End;

Procedure OMapEd.Show;
Begin
   OMap.Show;
End;

Procedure OMapEd.Run;

Var
   i, j    : Integer;
   Sprite  : PMemIcon;
   qtIcons : Byte;

   { Coloca apenas dois icones }

Begin
   For j := MAPHEIGHT DownTo 1 Do
   Begin
      For i := 1 To MAPWIDTH Do
      Begin
         If (Grid[i, j] <> Nil) Then
         Begin
            Grid[i, j]^.Run;
            If (Grid[i, j]^.Selected) Then
            Begin
               Select := True;
               if ((Grid[i,j].Code = 'USERA') or
                   (Grid[i,j].Code = 'USERB') or
                   (Grid[i,j].Code = 'USERC')) Then
                   ExistUser := False;
               Grid[i,j]^.Code := SelectedCode;
               Grid[i,j]^.SetType(SelectedElement);
               Grid[i,j]^.SetCourse(SelectedCourse);
               Grid[i,j]^.FreeIcons;

               Sprite := icList^.GetFirst;
               qtIcons := 0;
               While ((Sprite <> Nil) and (qtIcons < 2)) Do
               Begin
                  if (Sprite^.Code = Grid[i,j]^.Code) Then
                  Begin
                     Grid[i,j]^.SetIcon(Sprite^.Icon, Sprite^.Level);
                     inc(qtIcons);
                  End;
                  Sprite := icList^.GetNext;
               End;
               Grid[i,j]^.Complete;
               If (j > 1) Then Grid[i,j-1]^.Draw;
               Grid[i,j]^.Draw;
               If (j < MAPHEIGHT) Then Grid[i,j+1]^.OverDraw;
               {
                  For l := 1 To MAPHEIGHT Do Grid[i,l]^.Draw;
               }
             End;
         End;
      End;
   End;
   DrawGrid;
End;

Destructor OMapEd.Done;
Begin
   OMap.Done;
End;

End.