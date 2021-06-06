{**********************************************

       File : mapdb.pas
 Developper : Saulo Popov Zambiasi
Last Update : March/12/2002

ELEMENTS:

      1 - Sensor Presence         (all)
      2 - Sensor Sound/voice      (all)
      3 - Sensor Lightness        (Ligth)
      4 - Sensor Temperature      (Air-Condicionning, Ventilator)
      5 - Sensor Water            (Door/Window)
      6 - Sensor Grease (gordura) (Extractor)

     50 - Door
     51 - Window
     52 - Light
     53 - Stove (fogao)
     54 - Freezer
     55 - Microwave
     56 - Coffe Maker
     57 - Extractor (exaustor)
     58 - TV
     59 - Cable
     60 - Video K7
     61 - DVD
     62 - Sound Stereo
     63 - Computer
     64 - Air-condicionning
     65 - Ventilator
     66 - Showwer
     67 - Clothes wash
     68 - Clothes dryer

    100 - Floor
    101 - Wall
    102 - Table


**********************************************}

UNIT MapDB;

INTERFACE

USES
   Config;

CONST
   UNIT_USERA      = 253;
   UNIT_USERB      = 254;
   UNIT_USERC      = 255;

   { Devices Units }
   UNIT_PRESENCE    = 01;
   UNIT_VOICE       = 02;
   UNIT_LIGHTNESS   = 03;
   UNIT_TEMPERATURE = 04;
   UNIT_WATER       = 05;
   UNIT_GREASE      = 06;

   { Active Units }
   UNIT_DOOR       = 50;
   UNIT_WINDOW     = 51;
   UNIT_LIGHT      = 52;
   UNIT_STROVE     = 53;
   UNIT_FREEZER    = 54;
   UNIT_MICROWAVE  = 55;
   UNIT_COFFEMAKER = 56;
   UNIT_EXTRACTOR  = 57;
   UNIT_TV         = 58;
   UNIT_CABLE      = 59;
   UNIT_VIDEOK7    = 60;
   UNIT_DVD        = 61;
   UNIT_SOUND      = 62;
   UNIT_COMPUTER   = 63;
   UNIT_AIRCOND    = 64;
   UNIT_VENTILATOR = 65;
   UNIT_SHOWWER    = 66;
   UNIT_CLOTWASH   = 67;
   UNIT_CLOTDRYER  = 68;

   { Inactive Units }
   UNIT_VOID       = 000;
   UNIT_FLOOR      = 100;
   UNIT_WALL       = 101;
   UNIT_TABLE      = 102;


   UNIT_ACTIVE_BEGIN   =  50;
   UNIT_ACTIVE_END     =  68;

   UNIT_INACTIVE_BEGIN = 100;
   UNIT_INACTIVE_END   = 102;

   ALL             = 255;

   MAME_PRESENCE    = 'PRESENCA';
   MAME_VOICE       = 'VOZ';
   MAME_LIGHTNESS   = 'LUMINOSIDADE';
   MAME_TEMPERATURE = 'TEMPERATURA';
   MAME_WATER       = 'AGUA';
   MAME_GREASE      = 'GORDURA';

   NAME_USERA      = 'USERA';
   NAME_USERB      = 'USERB';
   NAME_USERC      = 'USERC';
   NAME_DOOR       = 'PORTA';
   NAME_WINDOW     = 'JANELA';
   NAME_LIGHT      = 'LUZ';
   NAME_STROVE     = 'FOGAO';
   NAME_FREEZER    = 'GELADEIRA';
   NAME_MICROWAVE  = 'MICROONDAS';
   NAME_COFFEMAKER = 'CAFETEIRA';
   NAME_EXTRACTOR  = 'EXAUSTOR';
   NAME_TV         = 'TV';
   NAME_CABLE      = 'CABO';
   NAME_VIDEOK7    = 'VIDEOK7';
   NAME_DVD        = 'DVD';
   NAME_SOUND      = 'SOM';
   NAME_COMPUTER   = 'COMPUTADOR';
   NAME_AIRCOND    = 'ARCONDICIONADO';
   NAME_VENTILATOR = 'VENTILADOR';
   NAME_SHOWWER    = 'CHUVEIRO';
   NAME_CLOTWASH   = 'LAVAROUPA';
   NAME_CLOTDRYER  = 'SECAROUPA';

   NAME_VOID       = 'VAZIO';
   NAME_FLOOR      = 'CHAO';
   NAME_WALL       = 'PAREDE';
   NAME_TABLE      = 'MESA';

   ELEMENTWIDTH    = 16;
   MAPWIDTH        = 30;
   MAPHEIGHT       = 20;
   MAX_UNITS       = 255;

TYPE

   NameFSize   = String[12];
   NameImgSize = String[5];

   SectorsMatrix = Array[1..MAPWIDTH, 1..MAPHEIGHT] of Byte;
   
   ABox = Record
      Element : Byte;
      Sector  : Byte;
      Course  : SetofCourse;
   End;

   ObjTypes = Record
      Name  : String;
      FName : String;
   End;


   MapReg = Record
      ImageFile : NameFSize;
      Grid      : Array [1..MAPWIDTH, 1..MAPHEIGHT] of ABox;
      Element   : Array [1..MAX_UNITS] of NameImgSize;
   End;


   PMapDB = ^OMapDB;
   OMapDB = Object
      MAPFILENAME : String;
      FMap     : File of MapReg;

      Constructor Init(tx : String);
      Procedure   Opendb;
      Procedure   Resetdb;
      Procedure   Closedb;
      Procedure   Put(Reg : MapReg);
      Function    Get(Var Reg : MapReg) : Boolean;
      Procedure   Clear(Var Reg : MapReg);
      Destructor  Done;
   End;

Var
   Objt : Array [0..255] of ObjTypes;

Procedure ClearImages(Var Reg : MapReg);
Procedure InitObjtypes;
Function  GetUnitCode(s : String) : Byte;
Function  GetUnitString(c : Byte) : String;
Procedure SetUnitFName(c : Byte; f : String);
Function  GetUnitFName(c : Byte) : String;
Function  GetUnitFCode(s : String) : Byte;


IMPLEMENTATION

{************************************************************


************************************************************}

Constructor OMapDB.Init(tx : String);
Begin
   MAPFILENAME := tx;
   Opendb;
End;

Procedure OMapDB.Opendb;

Var Reg : MapReg;

Begin
   Assign(FMap, MAPFILENAME);
   {$I-}
   Reset(FMap);
   {$I+}
   If IOresult <> 0 Then
   Begin
      ReWrite(FMap);
      Clear(Reg);
      Write(FMap, Reg);
   End;
End;

Procedure OMapDB.Resetdb;
Begin
   Reset(FMap);
End;

Procedure OMapDB.Closedb;
Begin
   Close(FMap);
End;

Procedure OMapDB.Clear(Var Reg : MapReg);

Var
   x, y : Integer;

Begin
   Reg.ImageFile := '';
   For y := 1 To MAPHEIGHT Do
      For x := 1 to MAPWIDTH Do
      Begin
         Reg.Grid[x, y].Element := UNIT_FLOOR;
         Reg.Grid[x, y].Sector  := 0;
         Reg.Grid[x, y].Course  := CDOWN;
      End;
   For x := 1 To MAX_UNITS Do
      Reg.Element[x] := '';
End;

Procedure OMapDB.Put(Reg : MapReg);
Begin
   Resetdb;
   Write(FMap, Reg);
End;

Function OMapDB.Get(Var Reg : MapReg) : Boolean;
Begin
   Resetdb;
   If (Not EOF(FMap)) Then
   Begin
      Read (FMap, Reg);
      Get := True;
   End Else Get := False;
End;

Destructor OMapDB.Done;
Begin
   Closedb;
End;

{*************************************************

         O T H E R - F U N C T I O N S

**************************************************}

Procedure ClearImages(Var Reg : MapReg);

var x : Integer;

Begin
   For x := 1 To MAX_UNITS Do
      Reg.Element[x] := '';
End;

{***************************************************

Mount a table of codes and names from objects types

****************************************************}

Procedure InitObjTypes;

Var i : Integer;

Begin
   For i := 0 To 255 Do
   Begin
      Objt[i].Name  := '';
      Objt[i].FName := '';
   End;

   Objt[UNIT_USERA].Name      := NAME_USERA;
   Objt[UNIT_USERB].Name      := NAME_USERB;
   Objt[UNIT_USERC].Name      := NAME_USERC;

   Objt[UNIT_DOOR].Name       := NAME_DOOR;
   Objt[UNIT_WINDOW].Name     := NAME_WINDOW;
   Objt[UNIT_LIGHT].Name      := NAME_LIGHT;
   Objt[UNIT_STROVE].Name     := NAME_STROVE;
   Objt[UNIT_FREEZER].Name    := NAME_FREEZER;
   Objt[UNIT_MICROWAVE].Name  := NAME_MICROWAVE;
   Objt[UNIT_COFFEMAKER].Name := NAME_COFFEMAKER;
   Objt[UNIT_EXTRACTOR].Name  := NAME_EXTRACTOR;
   Objt[UNIT_TV].Name         := NAME_TV;
   Objt[UNIT_CABLE].Name      := NAME_CABLE;
   Objt[UNIT_VIDEOK7].Name    := NAME_VIDEOK7;
   Objt[UNIT_DVD].Name        := NAME_DVD;
   Objt[UNIT_SOUND].Name      := NAME_SOUND;
   Objt[UNIT_COMPUTER].Name   := NAME_COMPUTER;
   Objt[UNIT_AIRCOND].Name    := NAME_AIRCOND;
   Objt[UNIT_VENTILATOR].Name := NAME_VENTILATOR;
   Objt[UNIT_SHOWWER].Name    := NAME_SHOWWER;
   Objt[UNIT_CLOTWASH].Name   := NAME_CLOTWASH;
   Objt[UNIT_CLOTDRYER].Name  := NAME_CLOTDRYER;

   { Inactive Objt[UNITs }
   Objt[UNIT_VOID].Name       := NAME_VOID;
   Objt[UNIT_FLOOR].Name      := NAME_FLOOR;
   Objt[UNIT_WALL].Name       := NAME_WALL;
   Objt[UNIT_TABLE].Name      := NAME_TABLE;
End;

{***************************************************

       Return code from object type name

****************************************************}

Function GetUnitCode(s : String) : Byte;

Var
   i, ret : Integer;
   found  : Boolean;

Begin
   i := 1;
   ret := 0;
   found := False;
   While ((i<=255) and (Not found)) Do
   Begin
      if (s = Objt[i].Name) Then
      Begin
         found := True;
         ret := i;
      End;
      i := i+1;
   End;
   GetUnitCode := ret;
End;

{***************************************************

        Return name from object type code

****************************************************}

Function GetUnitString(c : Byte) : String;

Var str : String;

Begin
   str := Objt[c].Name;
   if (str = '') Then GetUnitString := Objt[UNIT_USERA].Name
   Else GetUnitString := Objt[c].Name;
End;

Procedure SetUnitFName(c : Byte; f : String);
Begin
   Objt[c].FName := f;
End;

Function GetUnitFName(c : Byte) : String;
Begin
   GetUnitFName := Objt[c].FName;
End;

Function GetUnitFCode(s : String) : Byte;

Var
   i     : Integer;
   found : Boolean;
   ret   : Byte;

Begin
   i := 1;
   ret := 0;
   found := False;
   While ((i<=255) and (Not found)) Do
   Begin
      if (s = Objt[i].FName) Then
      Begin
         found := True;
         ret := i;
      End;
      i := i+1;
   End;
   GetUnitFCode := ret;
End;


End.
