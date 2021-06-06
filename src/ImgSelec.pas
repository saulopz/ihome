UNIT ImgSelec;

INTERFACE

USES
   Config, MyMouse, Objects, RollBoxs, Button,
   Icones, Collects, Boxs, MemIcons, UMenu,
   Labels, UGetFile, MapDB, ImgDB, UDialog, Graph;

TYPE

   PImageSelector = ^OImageSelector;
   OImageSelector = Object (OBox)
      FName      : NameFSize;
      IName      : NameFSize;
      Map        : MapReg;
      MyMapDB    : PMapDB;
      MyImgDB    : PImgDB;
      Menu       : OMenu;
      rbMap      : ORollBox;
      lbMap      : OLabel;
      icMap      : PIcon;
      rbFile     : ORollBox;
      lbFile     : OLabel;
      icFile     : PIcon;
      lbTest     : OLabel;


      Constructor Init(ix, iy : Integer; F : String; Tx : String; M : PMouse);
      Procedure   ChooseFile;
      Procedure   CloseFile;
      Procedure   Run; Virtual;
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Procedure   LoadImages;
      Function    GetIcon(code : String) : PIcon;
      Function    Confirmation : Boolean;
      Procedure   Save;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OImageSelector.Init(ix, iy : Integer; F : String; Tx : String; M : PMouse);

Begin
   InitObjTypes;
   FName := F;
   IName := '';
   MyImgDB := Nil;

   OBox.Init(ix, iy, 638, 478, False, 'Seletor de Imagens', True, M);

   New(MyMapDB, Init(FName));
   MyMapDB^.Get(Map);
   Dispose(MyMapDB, Done);

   Menu.Init(X+1, Y+16, 90, HORIZONTAL, '', False, Pointer);
   Menu.Add(1, True,  'Abrir');
   Menu.Add(2, True,  'Salvar');
   Menu.Add(3, False, 'Fechar');
   Menu.Add(4, False, 'Selecionar');
   Menu.Add(5, False, 'Limpar');
   Menu.Add(9, True,  'Sair');
   Menu.Draw;

   rbMap.Init(X+1, Y+55, 14, 10, 'Objetos', Pointer);
   rbMap.Add(NAME_AIRCOND);
   rbMap.Add(NAME_DOOR);
   rbMap.Add(NAME_CABLE);
   rbMap.Add(NAME_CLOTDRYER);
   rbMap.Add(NAME_CLOTWASH);
   rbMap.Add(NAME_COFFEMAKER);
   rbMap.Add(NAME_COMPUTER);
   rbMap.Add(NAME_DVD);
   rbMap.Add(NAME_EXTRACTOR);
   rbMap.Add(NAME_FLOOR);
   rbMap.Add(NAME_FREEZER);
   rbMap.Add(NAME_LIGHT);
   rbMap.Add(NAME_MICROWAVE);
   rbMap.Add(NAME_SHOWWER);
   rbMap.Add(NAME_SOUND);
   rbMap.Add(NAME_STROVE);
   rbMap.Add(NAME_TABLE);
   rbMap.Add(NAME_TV);
   rbMap.Add(NAME_WALL);
   rbMap.Add(NAME_WINDOW);
   rbMap.Add(NAME_USERA);
   rbMap.Add(NAME_USERB);
   rbMap.Add(NAME_USERC);
   rbMap.Add(NAME_VENTILATOR);
   rbMap.Add(NAME_VIDEOK7);
   rbMap.Draw;

   lbMap.Init(X+160, Y+55, '', Pointer);
   lbMap.Draw;
   New(icMap, Init(X+160, Y+70, 16, 32, Pointer));
   icMap^.Draw;

   rbFile.Init(X+400, Y+55, 10, 10, 'Imagens', Pointer);

   IName := Map.ImageFile;
   If (IName <> '') Then
   Begin
      New(MyImgDb, Init(IName));
      LoadImages;
      Menu.ActiveItem(3, True);
   End;

   lbFile.Init(X+300, Y+55, '', Pointer);
   lbFile.Draw;
   New(icFile, Init(X+300, Y+70, 16, 32, Pointer));
   icFile^.Draw;

   lbTest.Init( 100, 450, '', Pointer);
   lbTest.Draw;
End;

Function OImageSelector.Confirmation : Boolean;

Var dlg : PDialog;

Begin
   New(dlg, Init(170, 120, 300, 100, False, 'Confirmar', True, Pointer));
   dlg^.AddLine('Ao executar esta operacao, voce');
   dlg^.AddLine('estara apagando todas as imagens');
   dlg^.AddLine('do seu mapa. Voce confirma?');
   dlg^.AddButton(70, 15, 'Confirma', OK);
   dlg^.AddButton(70, 15, 'Cancela', CANCEL);
   dlg^.Draw;
   dlg^.Run;
   If (dlg^.btClick = OK) Then
      Confirmation := True
   Else Confirmation := False;
   dlg^.Clear;
   Dispose(dlg, Done);
   Draw;
End;

Procedure OImageSelector.ChooseFile;

Var gFile : PGetFile;

Begin
   New(gFile, Init(250, 100, 10, 'Imagens', '*.IMG', Pointer));
   gFile^.Run;

   If (gFile^.btClick = OK) Then
   Begin
      IName := gFile^.FileName;
      If (IName <> '') Then
      Begin
         LoadImages;
         Menu.ActiveItem(3, True);
      End;
   End;

   Dispose(gFile, Done);
   ClrScreen;
   Draw;
End;


Procedure OImageSelector.LoadImages;

Var
   iCode   : ImgCode;
   oldCode : ImgCode;
   iLevel  : Byte;
   iImage  : ImgSprite;

Begin
   if (rbFile.Size > 0) Then rbFile.Free;

   if (MyImgDB = Nil) Then
      New(MyImgDB, Init(IName));
   MyImgDB^.Resetdb;

   { Just take one of each name }
   oldCode := '';

   While (MyImgDb^.GetNext(iCode, iLevel, iImage)) Do
   Begin
      if (iCode <> oldCode) Then
      Begin
         oldCode := iCode;
         rbFile.Add(iCode);
      End;
   End;
   rbFile.Draw;
End;

Procedure OImageSelector.CloseFile;
Begin
   if (rbFile.Size > 0) Then rbFile.Free;
   If (MyImgDB <> Nil) Then
   Begin
      Dispose(MyImgDB, Done);
      MyImgDB := Nil;
   End;
   rbFile.Draw;
   icFile^.Clear;
   icFile^.Draw;
   lbFile.SetText('');
   lbFile.Draw;
   IName := '';
   Menu.ActiveItem(3, False);
End;


Function OImageSelector.GetIcon(code : String) : PIcon;

Var
   myIcon  : ImgSprite;
   sprite  : PIcon;
   i, j, a : Integer;

Begin
   sprite := Nil;
   If (MyImgDB^.Get(code, 0, myIcon)) Then
   Begin
      New(sprite, Init(0, 0, 16, 32, Pointer));
      a := 1;
      For j := 1 To 32 Do
      Begin
         For i := 1 To 16 Do
         Begin
            sprite^.PutPixelColor(i, j, myIcon[a]);
            inc(a);
         End;
      End;
   End;
   GetIcon := sprite;
End;

Procedure OImageSelector.Save;
Begin
   Map.ImageFile := IName;

   New(MyMapDB, Init(FName));
   MyMapDB^.Put(Map);
   Dispose(MyMapDB, Done);
End;

Procedure OImageSelector.Show;
Begin
   OBox.Show;
   Menu.Show;
   rbMap.Show;
   lbMap.Show;
   icMap^.Show;
   rbFile.Show;
   lbFile.Show;
   icFile^.Show;
   lbTest.Show;
End;

Procedure OImageSelector.Draw;
Begin
   OBox.Draw;
   Menu.Draw;
   rbMap.Draw;
   lbMap.Draw;
   icMap^.Draw;
   rbFile.Draw;
   lbFile.Draw;
   icFile^.Draw;
   lbTest.Draw;
End;

Procedure OImageSelector.Run;

Var
   Exit  : Boolean;
   iCode : String;
   icAux : PIcon;
   code  : Byte;
   change: Boolean;

Begin
   Exit   := False;
   Change := False;
   Repeat
      OBox.Run;
      Menu.Run;
      rbMap.Run;
      lbMap.Run;
      icMap^.Run;
      rbFile.Run;
      lbFile.Run;
      icFile^.Run;
      ScreenShow;

      { Menu }
      If (Menu.Selected) Then
      Begin
         Case (Menu.btClick) of
            1 : Begin
                   if (Map.ImageFile <> '') Then
                   Begin
                      If (Confirmation) Then
                      Begin
                         ClearImages(Map);
                         ChooseFile;
                         Change := True;
                      End;
                   End Else
                   Begin
                      ChooseFile;
                      Change := True;
                   End;
                End;
            2 : Save;
            3 : Begin
                   If (Confirmation) Then
                   Begin
                      ClearImages(Map);
                      CloseFile;
                      Change := True;
                   End;
                End;
            4 : Begin
                   icMap^.Copy(icFile);
                   icMap^.Draw;
                   iCode := rbMap.TextSelect;
                   Code  := GetUnitCode(iCode);
                   Map.Element[code] := lbFile.GetText;
                End;
            5 : Begin
                   icMap^.Clear;
                   icMap^.Draw;
                   iCode := rbMap.TextSelect;
                   Code  := GetUnitCode(iCode);
                   Map.Element[code] := '';
                End;
            9 : Exit := True;
         End;
      End;

      { Roll Box of Images from Image File }
      If (rbFile.Selected) Then
      Begin
         Change := True;
         iCode := rbFile.TextSelect;
         lbFile.SetText(iCode);
         lbFile.Draw;
         icAux := GetIcon(iCode);
         if (ICode <> '') Then
         Begin
            icFile^.Copy(icAux);
            Dispose(icAux, Done);
         End
         Else icFile^.Clear;
         icFile^.Draw;
      End;

      { Roll Box of Images from Map File }
      If (rbMap.Selected) Then
      Begin
         Change := True;
         iCode := rbMap.TextSelect;
         lbMap.SetText(iCode);
         lbMap.Draw;
         Code  := GetUnitCode(iCode);
         iCode := Map.Element[code];
         if (iCode <> '') Then
         Begin
            icAux  := GetIcon(iCode);
            icMap^.Copy(icAux);
            Dispose(icAux, Done);
         End
         Else icMap^.Clear;
         icMap^.Draw;
      End;

      If (Change) Then
      Begin
         If (lbMap.GetText <> '') Then
         Begin
            Menu.ActiveItem(5, True);
            If (lbFile.GetText <> '') Then
               Menu.ActiveItem(4, True)
            Else Menu.ActiveItem(4, False);
         End Else Menu.ActiveItem(5, False);
         Change := False;
      End;

   Until (Exit);
End;

Destructor OImageSelector.Done;
Begin
   CloseFile;
   Dispose(icMap, Done);
   Dispose(icFile, Done);
   lbFile.Done;
   rbFile.Done;
   lbMap.Done;
   rbMap.Done;
   Menu.Done;
   OBox.Done;
End;

End.