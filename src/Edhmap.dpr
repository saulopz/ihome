Program EdHMap;

uses
  Graph,
  Crt,
  MyMouse,
  Button,
  Rolls,
  Boxs,
  TextBoxs,
  RollBoxs,
  Objects,
  Labels,
  Config,
  UGetFile,
  UNewFile,
  UDialog,
  UMenu,
  UEditImg,
  MapDB,
  ImgSelec,
  UEditMap,
  SysUtils,
  USecEdit in 'USecEdit.pas',
  UElemSec in 'UElemSec.pas';

TYPE

   {*** Class OEditHomeMap ***}

   OEditHomeMap = Object (TObject)
      FileName : Str12;
      FileImage: Str12;
      GetFile  : PGetFile;
      NewFile  : PNewFile;
      Menu     : PMenu;

      Constructor Init(fullscreen : Boolean);
      Procedure   ChoseFile;
      Procedure   CreateNewFile;
      Procedure   ImagesSelector;
      Function    ExitProgram : Boolean;
      Procedure   Edit;
      Procedure   Run;  Virtual;
      Procedure   Draw; Virtual;
      Procedure   Show; Virtual;
      Destructor  Done;
   End;


{***************************************************

   Implementation of Object OEditHomeMap Methods

***************************************************}

Constructor OEditHomeMap.Init(fullscreen : Boolean);

Var
   Start : PDialog;

Begin
   InitGraph('EdHMap', fullscreen);

   New(Pointer, Init);
   TObject.Init(1, 1, 1, 1, Pointer);

   FileName := '';
   FileImage:= '';

   New(Start, Init(150, 100, 300, 170, False, 'Editor de Mapas', True, Pointer));
   Start^.AddLine('Programa para edicao de Mapas do');
   Start^.AddLine('prototipo da  dissertacao  sobre');
   Start^.AddLine('Automacao Residencial Usando IAD');
   Start^.AddLine('');
   Start^.AddLine('Autor  : Saulo Popov Zambiasi.');
   Start^.AddLine('Versao : 06.08.2002');
   Start^.AddButton(70, 15, 'Iniciar', OK);
   Start^.Draw;

   Pointer^.Show(True);

   Start^.Run;
   Dispose(Start, Done);
   ClrScreen;
End;

Procedure OEditHomeMap.ChoseFile;

Var
   MyMapDB : PMapDB;
   Reg     : MapReg;

Begin
   New(GetFile, Init(220, 100, 10, 'Mapa', '*.HMP', Pointer));
   GetFile^.Run;

   If (GetFile^.btClick = OK) Then
   Begin
      FileName := GetFile^.FileName;
      If (FileName <> '') Then
      Begin
         Menu^.ActiveItem(3, True);
         New(MyMapDB, Init(FileName));
         MyMapDB^.Get(Reg);
         FileImage := Reg.ImageFile;
         Dispose(MyMapDB, Done);
         If (FileImage <> '') Then Menu^.ActiveItem(4, True)
         Else Menu^.ActiveItem(4, False);
      End
      Else Begin
         Menu^.ActiveItem(3, False);
         Menu^.ActiveItem(4, False);
      End;
   End;

   Dispose(GetFile, Done);
   ClrScreen;
End;

Procedure OEditHomeMap.CreateNewFile;
Begin
   New(NewFile, Init(220, 100, 8, Pointer));
   NewFile^.Run;

   If (NewFile^.btClick = OK) Then
   Begin
      FileName := NewFile^.FileName+'.HMP';
      Menu^.ActiveItem(3, True);
   End;

   Dispose(NewFile, Done);
   ClrScreen;
End;

Procedure OEditHomeMap.ImagesSelector;

Var
   img : PImageSelector;

Begin
   New(img, Init(1, 1, FileName, 'Selecao de Imagens', Pointer));
   img^.Run;
   FileImage := img^.IName;
   Dispose(img, Done);

   Menu^.ActiveItem(4, (FileImage<>''));
   ClrScreen;
End;

Procedure OEditHomeMap.Edit;

Var
   EditMAP  : PEditMAP;

Begin
   New(EditMAP, Init(FileName, Pointer));
   EditMAP^.Run;
   Dispose(EditMAP, Done);
   ClrScreen;
End;

Function OEditHomeMap.ExitProgram : Boolean;

Var
   dlgExit  : PDialog;

Begin
   New(dlgExit, Init(220, 120, 200, 100, True, 'Sair', True, Pointer));
   dlgExit^.AddLine('Voce realmente deseja');
   dlgExit^.AddLine('sair do programa?');
   dlgExit^.AddButton(70, 15, 'Confirma', OK);
   dlgExit^.AddButton(70, 15, 'Cancela', CANCEL);
   dlgExit^.Draw;
   dlgExit^.Run;
   If (dlgExit^.btClick = OK) Then
      ExitProgram := True
   Else ExitProgram := False;
   dlgExit^.Clear;
   Dispose(dlgExit, Done);
End;

Procedure OEditHomeMap.Run;

Var
   Exit  : Boolean;

Begin
   Exit := False;

   New(Menu, Init(260, 50, 100, VERTICAL, 'Menu', True, Pointer));
   Menu^.Add(1, True,  'Abrir');
   Menu^.Add(2, True,  'Novo');
   Menu^.Add(3, False, 'Imagens');
   Menu^.Add(4, False, 'Editar');
   Menu^.Add(5, True,  'Sair');
   Menu^.Draw;

   Repeat
      Menu^.Run;
      ScreenShow;
      If (Menu^.Selected) Then
      Begin
         Case (Menu^.btClick) of
            1 : ChoseFile;
            2 : CreateNewFile;
            3 : ImagesSelector;
            4 : Edit;
            5 : Exit := ExitProgram;
         End;
         Menu^.ActiveItem(3, FileName <> '');
         Menu^.Text := FileName;
         Menu^.Draw;
      End;

   Until (Exit);

   Dispose(Menu, Done);
End;


Procedure OEditHomeMap.Draw;

Begin
   TObject.Draw;
End;


Procedure OEditHomeMap.Show;

Begin
   TObject.Show;
End;

Destructor OEditHomeMap.Done;

Begin
   Pointer^.Done;
   TObject.Done;
   CloseGraph;
End;


{******************************************************

                  Programa Princiapal

******************************************************}

Var
   Ed : OEditHomeMap;
   f  : Boolean;

Begin
   f := Not ((Paramstr(1) = 'w') or (Paramstr(1) = 'W'));
   Ed.Init(f);
   Ed.Run;
   Ed.Done;
End.