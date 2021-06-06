UNIT UMap;

INTERFACE

USES
   MyMouse, Graph, MapDB, ImgDB, Objects, Icones,
   Collects, MemIcons, UEleMap, Config, UMapObj;

TYPE
   PMap = ^OMap;
   OMap = Object (OMapObj)
      Gridline : Boolean;
      icFloor  : PIcon;
      icVoid   : PIcon;
      icList   : PCollection;
      Select   : Boolean;

      Constructor Init(ix, iy : Integer; iFile: String; M : PMouse);
      Procedure   Construct; Virtual;
      Procedure   Run;  Virtual;
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Procedure   DrawGrid;
      Procedure   Save;
      Procedure   SetSectors(sec : SectorsMatrix);
      Procedure   GetSectors(Var sec : SectorsMatrix);
      Function    Selected : Boolean;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OMap.Init(ix, iy : Integer; iFile: String; M : PMouse);

Var
   iCode   : ImgCode;
   iLevel   : Byte;
   sprite  : ImgSprite;
   icMem   : PMemIcon;
   MyImgDB : PImgDB;

Begin
   OMapObj.Init(ix, iy, iFile, M);
   Gridline := True;
   Select   := False;

   {*** Open a image db ***}
   New(MyImgDb, Init(IName));

   { Generate a void icon }
   New(icVoid, Init(0, 0, 16, 32, Pointer));
   If (MyImgDB^.Get(GetUnitFName(UNIT_VOID), 0, Sprite)) Then
      SpriteToIcon(Sprite, icVoid);
   icVoid^.Back := False;
   New(icFloor, Init(0, 0, 16, 32, Pointer));
   icFloor^.Back := False;
   If (MyImgDB^.Get(GetUnitFName(UNIT_FLOOR), 0, Sprite)) Then
      SpriteToIcon(Sprite, icFloor);
   MyImgDB^.Resetdb;

   New(icList, Init);
   While (MyImgDB^.GetNext(iCode, iLevel, Sprite)) Do
   Begin
      New(icMem, Init(iCode, iLevel, Pointer));
      icMem^.PutSprite(Sprite);
      icMem^.icon^.Back := False;
      icList^.InsertItem(icMem);
   End;
   Dispose(MyImgDB, Done);

   {*** Construct all map ***}
   Construct;
End;

Procedure OMap.Construct;

Var
   i, j     : Integer;
   pElem    : PElement;
   pIcMem   : PMemIcon;
   qtIcons  : Byte;

   { COLOCAR SO OS DOIS PRIMEIROS ICONES PARA EDICAO  }

Begin
   { Construct the Map, each element in grid }
   For j := 1 To MAPHEIGHT Do
      For i := 1 To MAPWIDTH Do
      Begin
         New(pElem, Init(X+(16*(i-1))+1, Y+(16*(j-1))+1, 16, 16,
                         Map.Grid[i, j].Element, icVoid, Pointer));
         pElem^.Sector := Map.Grid[i, j].Sector;
         pElem^.Course := Map.Grid[i, j].Course;
         pIcMem := icList^.GetFirst;
         qtIcons := 0;
         While ((pIcMem <> Nil) and (qtIcons < 2)) Do
         Begin
            if (pIcMem^.Code = pElem^.Code) Then
            Begin
               pElem^.SetIcon(pIcMem^.Icon, pIcMem^.Level);
               Inc(qtIcons);
            End;
            pIcMem := icList^.GetNext;
         End;
         pElem^.Complete;
         pElem^.SetFloor(icFloor);
         if ((pElem^.Code = GetUnitFName(UNIT_USERA)) or
             (pElem^.Code = GetUnitFName(UNIT_USERB)) or
             (pElem^.Code = GetUnitFName(UNIT_USERC))) Then ExistUser := True;
         Grid[i, j] := pElem;
      End;
End;

Procedure OMap.SetSectors(sec : SectorsMatrix);

Var i, j : Integer;

Begin
   For j := 1 To MAPHEIGHT Do
      For i := 1 To MAPWIDTH Do
         If (Grid[i, j] <> Nil) Then
            Grid[i, j]^.Sector := sec[i, j];
End;

Procedure OMap.GetSectors(Var sec : SectorsMatrix);

Var i, j : Integer;

Begin
   For j := 1 To MAPHEIGHT Do
      For i := 1 To MAPWIDTH Do
         If (Grid[i, j] <> Nil) Then
            sec[i, j] := Grid[i, j]^.Sector;
End;

Procedure OMap.Draw;

Var i, j : Integer;

Begin
   SetColor(Border);
   Line(x, y, x+Width, y);
   Line(x, y+Height+1, x+Width, y+Height+1);
   Line(x, y, x, y+Height+1);
   Line(x+Width, y, x+Width, y+Height+1);

   For j := 1 To MAPHEIGHT Do
      For i := 1 To MAPWIDTH Do
      Begin
         If (Grid[i, j] <> Nil) Then
            Grid[i, j]^.Draw;
      End;
   DrawGrid;
End;

Procedure OMap.DrawGrid;

Var i : Integer;

Begin
   If (Gridline) Then
   Begin
      SetColor({Backon} 0);
      For i := 1 To MAPWIDTH Do
         Line(x+(i*SPRITEWIDTH), y+1+SPRITEWIDTH, x+(i*SPRITEWIDTH), y+Height-1);
      For i := 2 To MAPHEIGHT Do
         Line(x+1, y+(i*SPRITEWIDTH), x+Width-1, y+(i*SPRITEWIDTH))
   End;
End;

Procedure OMap.Show;
Begin
   OMapObj.Show;
End;

Procedure OMap.Run;

Var
   i, j   : Integer;

Begin
   For j := 1 To MAPHEIGHT Do
   Begin
      For i := 1 To MAPWIDTH Do
      Begin
         If (Grid[i, j] <> Nil) Then
         Begin
            Grid[i, j]^.Run;
            If (Grid[i, j]^.Selected) Then
            Begin
               Grid[i, j]^.Draw;
               Select := True;
            End;
         End;
      End;
   End;
End;

Procedure OMap.Save;

Var ci, cj   : Integer;

Begin
   cj := 1;
   While (cj <= MAPHEIGHT) Do
   Begin
      ci := 1;
      While (ci <= MAPWIDTH) Do
      Begin
         Map.Grid[ci,cj].Element := GetUnitFCode(Grid[ci,cj].GetCode);
         Map.Grid[ci,cj].Sector  := Grid[ci,cj].Sector;
         Map.Grid[ci,cj].Course  := Grid[ci,cj].Course;
         ci := ci+1;
      End;
      cj := cj+1;
   End;
   New(MyMapDB, Init(FName));
   MyMapDB^.Put(Map);
   MyMapDB^.Done;
End;

Function OMap.Selected : Boolean;
Begin
   Selected := Select;
   Select   := False;
End;

Destructor OMap.Done;
Begin
   Dispose(IcFloor, Done);
   Dispose(IcVoid, Done);
   Dispose(icList, Done);
   OMapObj.Done;
End;

End.