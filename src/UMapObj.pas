unit UMapObj;

INTERFACE

USES
   MyMouse, Graph, MapDB, ImgDB, Objects, Icones,
   Collects, MemIcons, UEleMap, Config, Devices;

CONST
   SPRITEWIDTH  = 16;
   SPRITEHEIGHT = 32;

TYPE
   PMapObj = ^OMapObj;
   OMapObj = Object (TObject)
      FName      : NameFSize;
      IName      : NameFSize;
      Map        : MapReg;
      MyMapDB    : PMapDB;
      Grid       : TGrid;
      ExistUser  : Boolean;

      Constructor Init(ix, iy : Integer; iFile: String; M : PMouse);
      Procedure   Construct; Virtual;
      Procedure   Run;  Virtual;
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Procedure   SpriteToIcon(sprite : ImgSprite; ic :PIcon);
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OMapObj.Init(ix, iy : Integer; iFile: String; M : PMouse);

Begin
   TObject.Init(ix, iy, (MapWIDTH*SPRITEWIDTH)+2, (MapHEIGHT*SPRITEWIDTH)+SPRITEWIDTH, M);
   FName     := iFile;
   ExistUser := False;

   { Get MapObj from File }
   New(MyMapDB, Init(FName));
   MyMapDB^.Get(Map);
   Dispose(MyMapDB, Done);
   IName := Map.ImageFile;
End;

Procedure OMapObj.Construct;
Begin
End;

Procedure OMapObj.Draw;
Begin
End;

Procedure OMapObj.Show;
Begin
   TObject.Show;
End;

Procedure OMapObj.Run;
Begin
End;

Procedure  OMapObj.SpriteToIcon(sprite : ImgSprite; ic : PIcon);

Var
   i, j, l : Integer;

Begin
   l := 1;
   For j := 1 to SPRITEHEIGHT Do
      For i := 1 to SPRITEWIDTH Do
      Begin
         ic^.PutPixelColor(i, j, sprite[l]);
         inc(l);
      End;
End;

Destructor OMapObj.Done;

Var
  i, j : Integer;

Begin
   For j := 1 To MapHEIGHT Do
      For i := 1 To MapWIDTH Do
         If (Grid[i, j] <> Nil) Then Dispose(Grid[i, j], Done);
   TObject.Done;
End;

end.
