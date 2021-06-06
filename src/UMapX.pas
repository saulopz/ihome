UNIT UMapX;

INTERFACE

USES
   MyMouse, Graph, MapDB, ImgDB, Objects, Icones,
   Collects, MemIcons, UEleMapX, Config, Devices,
   UMapObj, UEleUser, UEleMap, USectors, UShell;

TYPE
   PMapX = ^OMapX;
   OMapX = Object (OMapObj)
      pUser         : PElementUser;
      icList        : PCollection;
      SelectedX     : Integer;
      SelectedY     : Integer;
      ChangeObj     : Boolean;
      Sector        : PSector;
      Temperature   : Byte;
      oldTemp       : Byte;
      Lightness     : Byte;
      oldLight      : Byte;
      Water         : Byte;
      oldWater      : Byte;
      uSectorChange : Boolean;
      NewEnvironment: Boolean;
      icVoid        : PIcon;
      icFloor       : Array [0..3] of PIcon;

      Constructor Init(ix, iy : Integer; iFile: String; M : PMouse);
      Procedure   Construct; Virtual;
      Procedure   Run;  Virtual;
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Function    Command(cmd : String) : String;
      Procedure   SetuSector(sec : Byte);
      Procedure   DrawWalk;
      Procedure   SetEnvironment;
      Function    uSectorChanged : Boolean;
      Function    ChangeObject : Boolean;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OMapX.Init(ix, iy : Integer; iFile: String; M : PMouse);

Var
   iCode   : ImgCode;
   iLevel  : Byte;
   sprite  : ImgSprite;
   icMem   : PMemIcon;
   MyImgDB : PImgDB;
   i       : Integer;

Begin
   OMapObj.Init(ix, iy, iFile, M);
   SelectedX  := 1;
   SelectedY  := 1;
   ChangeObj  := False;
   pUser      := Nil;
   Sector     := Nil;
   uSectorChange := False;
   NewEnvironment := False;
   Temperature := 23;
   oldTemp     := 0;
   Lightness   := 1;
   oldLight    := 0;
   Water       := 0;
   oldWater    := 0;
   For i := 0 To 3 Do icFloor[i] := Nil;

   {*** Open a image db ***}
   New(MyImgDb, Init(IName));

   { Generate a void icon }
   New(icVoid, Init(0, 0, 16, 32, Pointer));
   If (MyImgDB^.Get(GetUnitFName(UNIT_VOID), 0, Sprite)) Then
      SpriteToIcon(Sprite, icVoid);
   icVoid^.Back := False;
   MyImgDB^.Resetdb;

   { Put all icons in memory }
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
   if (pUser <> Nil) Then pUser.SetMap(@Grid);
End;

Procedure OMapX.Construct;

Var
   i, j     : Integer;
   pElem    : PElementX;
   pIcMem   : PMemIcon;
   Dev      : PDevice;

Begin
   New(Sector, Init);
   Sector^.Add(0, UNIT_VOID, Nil);

   { Construct floor icons }
   i := 0;
   pIcMem := icList^.GetFirst;
   While (pIcMem <> Nil) Do
   Begin
      If (pIcMem^.Code = GetUnitFName(UNIT_FLOOR)) Then
      Begin
         icFloor[i] := pIcMem^.icon;
         i := i+1;
      End;
      pIcMem := icList^.GetNext;
   End;
   For i := 0 To 3 Do
      If (icFloor[i] = Nil) Then icFloor[i] := icVoid;

   { Construct the Map, each element in grid }
   For j := 1 To MAPHEIGHT Do
      For i := 1 To MAPWIDTH Do
      Begin
         If ((Map.Grid[i,j].Element = UNIT_USERA) or
             (Map.Grid[i,j].Element = UNIT_USERB) or
             (Map.Grid[i,j].Element = UNIT_USERC)) Then
         Begin
            ExistUser := True;
            New(pUser, Init(X+(16*(i-1))+1, Y+(16*(j-1))+1, 16, 16,
                            Map.Grid[i, j].Element, icVoid, Pointer));
            // pUser^.Sector := Map.Grid[i, j].Sector;
            SetuSector(Map.Grid[i, j].Sector);
            pUser^.Course := Map.Grid[i, j].Course;
            pIcMem := icList^.GetFirst;
            While (pIcMem <> Nil) Do
            Begin
               if (pIcMem^.Code = GetUnitFName(UNIT_USERA)) Then
                  pUser^.SetUserIcon('a', pIcMem^.Icon, pIcMem^.Level);
               if (pIcMem^.Code = GetUnitFName(UNIT_USERB)) Then
                  pUser^.SetUserIcon('b', pIcMem^.Icon, pIcMem^.Level);
               if (pIcMem^.Code = GetUnitFName(UNIT_USERC)) Then
                  pUser^.SetUserIcon('c', pIcMem^.Icon, pIcMem^.Level);
               pIcMem := icList^.GetNext;
            End;
            // pUser^.Complete;
            PUser^.MyX := i;
            PUser^.MyY := j;
            Map.Grid[i,j].Element := UNIT_FLOOR;
         End;
         New(pElem, Init(X+(16*(i-1))+1, Y+(16*(j-1))+1, 16, 16,
                         Map.Grid[i, j].Element, icVoid, Pointer));
         pElem^.Sector := Map.Grid[i, j].Sector;
         pElem^.Course := Map.Grid[i, j].Course;
         pElem^.SetFloor(icFloor[0]);
         pIcMem := icList^.GetFirst;
         While (pIcMem <> Nil) Do
         Begin
            if (pIcMem^.Code = pElem^.Code) Then
               pElem^.SetIcon(pIcMem^.Icon, pIcMem^.Level);
            pIcMem := icList^.GetNext;
         End;
         pElem^.Complete;
         // Inicializa os dispositivos
         If ((Map.Grid[i,j].Element >= 50) and (Map.Grid[i,j].Element < 100)) Then
         Begin
            New(Dev, Init);
            pElem^.SetDevice(Dev);
            Sector^.Add(Map.Grid[i,j].Sector, Map.Grid[i,j].Element, Dev);
         End;
         Grid[i, j] := pElem;
      End;
End;

Procedure OMapX.SetuSector(sec : Byte);
Begin
   If (Sector <> Nil) Then
   Begin
      Sector^.SetDevice(UNIT_PRESENCE, 0, ALL, ALL, ALL);
      Sector^.SetDevice(UNIT_PRESENCE, 1, ALL, ALL, pUser^.Sector);
   End;
End;

Function OMapX.uSectorChanged : Boolean;
Begin
   uSectorChanged := uSectorChange;
   uSectorChange  := False;
End;

Procedure OMapX.SetEnvironment;

Var
   i, j : Integer;
   dev  : PDevice;
   aux  : PIcon;

Begin
   For j := 1 To MAPHEIGHT Do
   Begin
      For i := 1 To MAPWIDTH Do
      Begin
         If (Grid[i, j] <> Nil) Then
            Begin
               aux := Grid[i,j]^.Floor;
               If (Grid[i,j]^.Sector <> 0) Then
               Begin
                  If (Lightness = 0) Then
                  Begin
                     dev := Sector^.GetDevice(UNIT_LIGHT, Grid[i,j]^.Sector);
                     If (dev <> Nil) Then
                     Begin
                        If (Dev^.On = 1) Then Grid[i,j]^.SetFloor(icFloor[0])
                        Else Grid[i,j]^.SetFloor(icFloor[1]);
                     End;
                  End Else Grid[i,j]^.SetFloor(icFloor[0]);
               End
               Else
               Begin
                  If (Lightness = 1) Then
                  Begin
                     If ((Water = 0) or (Grid[i,j]^.Sector <> 0)) Then
                        Grid[i,j]^.SetFloor(icFloor[0])
                     Else Grid[i,j]^.SetFloor(icFloor[2]);
                  End Else
                  Begin
                     If ((Water = 0) or (Grid[i,j]^.Sector <> 0)) Then
                        Grid[i,j]^.SetFloor(icFloor[1])
                     Else Grid[i,j]^.SetFloor(icFloor[3]);
                  End;
               End;
               If (aux <> Grid[i,j]^.Floor) Then NewEnvironment := True;
          End;
      End;
   End;
End;

{*******************************************************************

   GET AND EXECUTE A EXTERNAL COMMAND

*******************************************************************}

Function OMapX.Command(cmd : String) : String;

Var
   cmdReturn : String;
   error     : String;
   Value     : Byte;
   code      : Integer;

Begin
   ChangeObj := True;
   error     := 'NULL';
   cmdReturn := 'NULL';
   If (Pos('DIA', cmd) <> 0) Then
   Begin
      Lightness := 1;
      SetEnvironment;
   End
   Else If (Pos('NOITE', cmd) <> 0) Then
   Begin
      Lightness := 0;
      SetEnvironment;
   End
   Else If (Pos('LIMPO', cmd) <> 0) Then
   Begin
      Water := 0;
      SetEnvironment;
   End
   Else If (Pos('CHUVA', cmd) <> 0) Then
   Begin
      Water := 1;
      SetEnvironment;
   End
   Else If (Pos('TEMPERATURA', cmd) <> 0) Then
   Begin
      Val(Copy(cmd, 13, 2), Value, Code);
      If (Code = 0) Then Temperature := Value;
   End
   Else If (Pos('SAIR', cmd) <> 0) Then
   Begin
      error := 'EXIT';
   End
   Else
   Begin
      // pUser^.Sector := 2;
      error := Shell(cmd, cmdReturn, pUser^.Sector);
      If (error <> 'NULL') Then cmdReturn := error
      Else Sector.CommandVoice(pUser^.Sector, cmdReturn);
   End;
   Command := error;
End;

Procedure OMapX.Draw;

Var i, j : Integer;

Begin
   For j := 1 To MAPHEIGHT Do
      For i := 1 To MAPWIDTH Do
         If (Grid[i, j] <> Nil) Then Grid[i, j]^.Draw;
   DrawWalk;
   Grid[SelectedX, SelectedY]^.DrawBorder;
   SetColor(Border);
   Line(X, Y, X+Width-1, Y);
   Line(X, Y+Height+1, X+Width-1, Y+Height+1);
   Line(X, Y, X, Y+Height+1);
   Line(X+Width-1, Y, X+Width-1, Y+Height+1);
End;

Procedure OMapX.DrawWalk;

Var i, j : Integer;

Begin
   if (pUser <> Nil) Then
   Begin
      For j := pUser^.MyY-2 To pUser^.MyY+2 Do
      Begin
         For i := pUser^.MyX-1 To pUser^.MyX+1 Do
         Begin
            If ((i <= MAPWIDTH) and (i > 0) and (j <= MAPHEIGHT) and (j > 0)) Then
            Begin
               If (j = pUser^.MyY+2) Then Grid[i,j]^.OverDraw
               Else Grid[i,j]^.Draw;
            End;
         End;
         If (j = pUser^.MyY) Then pUser^.Draw;
         If (pUser^.NextY > pUser^.MyY) Then
         Begin
            If (j = pUser^.NextY) Then
               pUser^.Draw
         End
         Else If (j = pUser^.MyY) Then pUser^.Draw;
      End;
   End;
End;

Procedure OMapX.Show;
Begin
   OMapObj.Show;
End;

Procedure OMapX.Run;

Var
   i, j : Integer;
   chg  : Boolean;

Begin
   If (Grid[pUser^.MyX, pUser^.MyY].Sector <> pUser^.Sector) Then
   Begin
      pUser^.Sector := Grid[pUser^.MyX, pUser^.MyY].Sector;
      uSectorChange := True;
      SetEnvironment;
   End;

   If (uSectorChanged) Then
      SetuSector(Grid[pUser^.MyX, pUser^.MyY]^.Sector);

   For j := 1 To MAPHEIGHT Do
   Begin
      For i := 1 To MAPWIDTH Do
      Begin
         If (Grid[i, j] <> Nil) Then
         Begin
            Grid[i, j]^.Run;
            If (Grid[i,j]^.Dev <> Nil) Then
            Begin
               chg := Grid[i,j]^.Changed;
               If ((Grid[i,j]^.Dev^.On = 1) Or (chg)) Then
               Begin
                  If (chg) Then ChangeObj := True;
                  If (j > 1) Then Grid[i,j-1]^.Draw;
                  Grid[i,j]^.Draw;
                  If (j < MAPHEIGHT) Then
                  Begin
                     If (Grid[i,j+1]^.Code <> GetUnitFName(UNIT_FLOOR)) Then
                        Grid[i,j+1]^.OverDraw;
                  End;
                  If ((i=SelectedX) and (j=SelectedY)) Then Grid[i,j]^.DrawBorder;
               End;
            End;
            If (Grid[i, j]^.Select) Then
            Begin
               If ((i<>SelectedX) or (j<>SelectedY)) Then
               Begin
                  Grid[SelectedX, SelectedY]^.Select := False;
                  Grid[SelectedX, SelectedY]^.Draw;
                  If (SelectedY < MAPHEIGHT) Then
                     Grid[SelectedX, SelectedY+1]^.OverDraw;
                  SelectedX := i;
                  SelectedY := j;
                  ChangeObj := True;
               End;
            End Else If (Grid[i,j]^.ifGo) Then
            Begin
               if (pUser <> Nil) Then pUser^.GotoXY(i, j);
            End;
         End;
      End;
   End;

   pUser^.Run;
   if (pUser <> Nil) Then DrawWalk;
   Grid[SelectedX, SelectedY]^.DrawBorder;

   If (oldTemp <> Temperature) Then
   Begin
      Sector^.SetDevice(UNIT_TEMPERATURE, 0, Temperature, ALL, ALL);
      oldTemp := Temperature;
   End;
   If (oldLight <> Lightness) Then
   Begin
      Sector^.SetDevice(UNIT_LIGHTNESS, Lightness, ALL, ALL, ALL);
      oldLight := Lightness;
   End;
   If (oldWater <> Water) Then
   Begin
      Sector^.SetDevice(UNIT_WATER, Water, 0, ALL, ALL);
      oldWater := Water;
   End;

   Sector.Run;
   If (Sector^.Super.Changed) Then
   Begin
      SetEnvironment;
      //ChangeObj := True;
   End;

   If (NewEnvironment) Then
   Begin
      Draw;
      NewEnvironment := False;
   End;
End;

Function OMapX.ChangeObject : Boolean;
Begin
   ChangeObject := ChangeObj;
   ChangeObj := False;
End;

Destructor OMapX.Done;
Begin
   Dispose(IcVoid, Done);
   Dispose(icList, Done);
   If (Sector <> Nil) Then Dispose(Sector, Done);
   OMapObj.Done;
End;

End.