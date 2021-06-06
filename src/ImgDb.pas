{**********************************************

       File : imgdb.pas
 Developper : Saulo Popov Zambiasi
Last Update : March/09/2002

INFORMATIONS:

   This object control the database of sprites
   images of environment. The structure of each
   sprite is:

   [ CODE | LEVEL | IMAGE ]
      |       |       |
      |       |       +----- 256 Bytes
      |       +-------------   1 Byte
      +---------------------   5 Bytes
                             ---------
                             262 Bytes

**********************************************}

UNIT ImgDB;

INTERFACE

USES
   Config;

CONST
   TEMPFILENAME    = 'TEMP.IMG';
   SPRITEIMGSIZE   = 512; { 16 X 32 }
   SPRITEFILESIZE  = 256; {  8 X 32 }

TYPE
   ImgCode    = String[5];
   ImgSprite  = Array[1..SPRITEIMGSIZE]  of Byte;
   FileSprite = Array[1..SPRITEFILESIZE] of Byte;

   ImgReg = Record
      Code  : ImgCode;
      Level : Byte;
      Image : FileSprite;
   End;

   PImgDB = ^OImgDB;
   OImgDB = Object
      IMGFILENAME : String;
      FileImg     : File of ImgReg;

      Constructor Init(tx : String);
      Procedure   Opendb;
      Procedure   Resetdb;
      Procedure   Closedb;
      Procedure   Put(C : ImgCode; L : Byte; I : ImgSprite);
      Function    Get(C : ImgCode; L : Byte; Var I : ImgSprite) : Boolean;
      Function    GetSizeCode(C : ImgCode) : Integer;
      Function    GetNext(Var C : ImgCode; Var L : Byte; Var I : ImgSprite) : Boolean;
      Procedure   Cut(C : ImgCode; L : Byte);
      Function    GetHeader(Var C : ImgCode; Var L : Byte) : Boolean;
      Function    Exist(C : ImgCode; L : Byte) : Boolean;
      Function    ExistCode(C : ImgCode) : Boolean;
      Procedure   SpriteToFile(Imgin : ImgSprite; Var ImgOut  : FileSprite);
      Procedure   SpriteToImg (Imgin : FileSprite; Var ImgOut : ImgSprite);
      Procedure   Order;
      Destructor  Done;
   End;

IMPLEMENTATION

{************************************************************


************************************************************}

Constructor OImgDB.Init(tx : String);

Begin
   IMGFILENAME := tx;
   Opendb;
End;

Procedure OImgDB.Opendb;

Begin
   Assign(FileImg, IMGFILENAME);
   {$I-}
   Reset(FileImg);
   {$I+}
   If IOresult <> 0 Then ReWrite(FileImg);
End;

Procedure OImgDB.Resetdb;

Begin
   Reset(FileImg);
End;

Procedure OImgDB.Closedb;

Begin
   Close(FileImg);
End;

Function OImgDB.Exist(C : ImgCode; L : Byte) : Boolean;

Var
   Reg   : ImgReg;
   Found : Boolean;

Begin
   Found := False;

   Resetdb;

   While ((Not Eof(FileImg)) and (Not Found)) Do
   Begin
      Read(FileImg, Reg);
      If ((Reg.Code = C) and (Reg.Level = L)) Then
      Begin
         Found := True;
      End;
   End;

   Resetdb;

   Exist := Found;
End;

Function OImgDB.ExistCode(C : ImgCode) : Boolean;

Var
   Reg   : ImgReg;
   Found : Boolean;

Begin
   Found := False;

   Resetdb;

   While ((Not Eof(FileImg)) and (Not Found)) Do
   Begin
      Read(FileImg, Reg);
      If (Reg.Code = C) Then
      Begin
         Found := True;
      End;
   End;

   Resetdb;

   ExistCode := Found;
End;

Function OImgDB.GetHeader(Var C : ImgCode; Var L : Byte) : Boolean;

Var
   Reg : ImgReg;

Begin
   If (Not Eof(FileImg)) Then
   Begin
      Read(FileImg, Reg);
      C := Reg.Code;
      L := Reg.Level;
      GetHeader := True;
   End
   Else Begin
      GetHeader := False;
      C := '';
      L := 0;
   End;
End;

Function OImgDB.GetNext(Var C : ImgCode; Var L : Byte; Var I : ImgSprite) : Boolean;

Var
   Reg : ImgReg;

Begin
   If (Not Eof(FileImg)) Then
   Begin
      Read(FileImg, Reg);
      C := Reg.Code;
      L := Reg.Level;
      SpriteToImg(Reg.Image, I);
      GetNext := True;
   End
   Else Begin
      GetNext := False;
      C := '';
      L := 0;
   End;
End;

Function OImgDB.GetSizeCode(C : ImgCode) : Integer;

Var
   Reg    : ImgReg;
   MySize : Integer;

Begin
   Resetdb;
   MySize := 0;
   While (Not Eof(FileImg)) Do
   Begin
      Read(FileImg, Reg);
      if (Reg.Code = C) Then Inc(MySize);
   End;
   Resetdb;
   GetSizeCode := MySize;
End;

Procedure OImgDB.Put(C : ImgCode; L : Byte; I : ImgSprite);

Var
   FSprite : FileSprite;
   Reg     : ImgReg;
   Found   : Boolean;

Begin
   SpriteToFile(I, FSprite);

   C := StringUpper(C);

   If (Exist(C, L)) Then
   Begin
      Found := False;
      While ((Not Eof(FileImg)) and (Not Found)) Do
      Begin
         Read(FileImg, Reg);
         If ((Reg.Code = C) and (Reg.Level = L)) Then
         Begin
            Seek(FileImg, FilePos(FileImg)-1);
            Reg.Code  := C;
            Reg.Level := L;
            SpriteToFile(I, Reg.Image);
            Write(FileImg, Reg);
            Found := True;
         End;
      End;
   End
   Else Begin
      Seek(FileImg, FileSize(FileImg));
      Reg.Code  := C;
      Reg.Level := L;
      SpriteToFile(I, Reg.Image);
      Write(FileImg, Reg);
      Order;
   End;
   Closedb;
   Opendb;
End;

Function OImgDB.Get(C : ImgCode; L : Byte; Var I : ImgSprite) : Boolean;

Var
   Reg   : ImgReg;
   Found : Boolean;

Begin
   Found := False;

   Resetdb;

   While ((Not Eof(FileImg)) and (Not Found)) Do
   Begin
      Read(FileImg, Reg);
      If ((Reg.Code = C) and (Reg.Level = L)) Then
      Begin
         SpriteToImg(Reg.Image, I);
         Found := True;
      End;
   End;
   Resetdb;
   Get := Found;
End;

Procedure OImgDB.Cut(C : ImgCode; L : Byte);

Var
   Reg   : ImgReg;
   Temp  : File of ImgReg;

Begin
   Resetdb;
   Assign(Temp, TEMPFILENAME);
   ReWrite(Temp);

   While (Not Eof(FileImg)) Do
   Begin
      Read(FileImg, Reg);
      If ((Reg.Code <> C) or (Reg.Level <> L)) Then
      Begin
         Write(Temp, Reg);
      End;
   End;

   Close(Temp);
   Closedb;
   Erase(FileImg);
   Rename(Temp, IMGFILENAME);
   Opendb;
End;

Procedure OImgDB.SpriteToFile(Imgin : ImgSprite; Var ImgOut : FileSprite);

Var
   i, j : Integer;

Begin
   i := 1;
   j := 1;
   While (i <= SPRITEFILESIZE) Do
   Begin
      ImgOut[i] := (ImgIn[j] shl 4) or ImgIn[j+1];
      i := i + 1;
      j := j + 2;
   End;
End;

Procedure OImgDB.SpriteToImg (Imgin : FileSprite; Var ImgOut: ImgSprite);

Var
   i, j : Integer;

Begin
   i := 1;
   j := 1;
   While (i <= SPRITEFILESIZE) Do
   Begin
      ImgOut[j]   := (ImgIn[i] and $F0) shr 4;
      ImgOut[j+1] :=  ImgIn[i] and $0F;
      i := i + 1;
      j := j + 2;
   End;
End;

Procedure OImgDB.Order;

Var
   Reg, Rt : ImgReg;
   Raux    : ImgReg;
   Menor   : String[6];
   Item    : String[6];
   a, b    : Integer;
   c, i    : Integer;
   Change  : Boolean;


Begin
   Resetdb;

   i := FileSize(FileImg);

   If (Not EOF(FileImg)) Then
   Begin
      For a := 1 To i-1 Do
      Begin
         Change := False;
         c := a;
         Seek(FileImg, a-1);
         Read(FileImg, Rt);
         Menor := Rt.Code + Chr(Rt.Level);

         For b := a+1 To i Do
         Begin
            Seek(FileImg, b-1);
            Read(FileImg, Reg);
            Item := Reg.Code + Chr(Reg.Level);
            If (Item < Menor) Then
            Begin
               c      := b;
               Menor  := Item;
               Rt     := Reg;
               Change := True;
            End;
         End;

         If (Change) Then
         Begin
            Seek (FileImg, a-1);
            Read (FileImg, Raux);
            Seek (FileImg, c-1);
            Write(FileImg, Raux);
            Seek (FileImg, a-1);
            Write(FileImg, Rt);
         End;
      End;
   End;
   Resetdb;
End;

Destructor OImgDB.Done;

Begin
   Closedb;
End;


End.
