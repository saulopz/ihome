Program EdSprite;

Uses
   SysUtils, Graph, {Crt,} MyMouse, Button, Rolls,
   Boxs, TextBoxs, RollBoxs, Objects,
   Labels, Config, UGetFile, UNewFile,
   UDialog, UMenu, UEditImg;

TYPE

   {*** Class OEditSprite ***}

   OEditSprite = Object (TObject)
      FileName : Str12;
      GetFile  : PGetFile;
      NewFile  : PNewFile;
      Start    : PDialog;
      dlgExit  : PDialog;
      EditImg  : PEditIMG;
      Menu     : PMenu;

      Constructor Init(fullscreen : Boolean);
      Procedure   ChoseFile;
      Procedure   CreateNewFile;
      Function    ExitProgram : Boolean;
      Procedure   Edit;
      Procedure   Run;  Virtual;
      Procedure   Draw; Virtual;
      Procedure   Show; Virtual;
      Destructor  Done;
   End;


{***************************************************

   Implementation of Object OEditSprite Methods

***************************************************}

Constructor OEditSprite.Init(fullscreen : Boolean);

Begin
   InitGraph('EdSprite', fullscreen);

   New(Pointer, Init);
   TObject.Init(1, 1, 1, 1, Pointer);

   FileName := '';

   New(Start, Init(150, 100, 300, 170, False, 'Editor de Imagens', True, Pointer));
   Start^.AddLine('Programa  para  edicao  de  Imagens');
   Start^.AddLine('do prototipo da  dissertacao  sobre');
   Start^.AddLine('Automacao    Residencial     Usando');
   Start^.AddLine('Inteligencia Artificial Distribuida.');
   Start^.AddLine('');
   Start^.AddLine('Autor  : Saulo Popov Zambiasi.');
   Start^.AddLine('Versao : 2002.03.12');
   Start^.AddButton(70, 15, 'Iniciar', OK);
   Start^.Draw;

   Pointer^.Show(True);

   Start^.Run;
   Dispose(Start, Done);
   ClrScreen;
End;

Procedure OEditSprite.ChoseFile;
Begin
   New(GetFile, Init(220, 100, 10, 'Imagens', '*.IMG', Pointer));
   GetFile^.Run;

   If (GetFile^.btClick = OK) Then
      FileName := GetFile^.FileName;

   Dispose(GetFile, Done);
   ClrScreen;
End;

Procedure OEditSprite.CreateNewFile;
Begin
   New(NewFile, Init(220, 100, 8, Pointer));
   NewFile^.Run;

   If (NewFile^.btClick = OK) Then
      FileName := NewFile^.FileName+'.IMG';

   Dispose(NewFile, Done);
   ClrScreen;
End;

Procedure OEditSprite.Edit;
Begin
  New(EditImg, Init(FileName, Pointer));
  EditImg^.Run;
  Dispose(EditImg, Done);
  ClrScreen;
End;

Function OEditSprite.ExitProgram : Boolean;
Begin
   New(dlgExit, Init(220, 100, 200, 100, True, 'Sair', True, Pointer));
   dlgExit^.AddLine('Voce realmente deseja');
   dlgExit^.AddLine('sair do programa?');
   dlgExit^.AddButton(70, 15, 'Confirma', OK);
   dlgExit^.AddButton(70, 15, 'Cancela', CANCEL);
   dlgExit^.Draw;
   dlgExit^.Run;
   ScreenShow;
   If (dlgExit^.btClick = OK) Then
      ExitProgram := True
   Else ExitProgram := False;
   dlgExit^.Clear;
   Dispose(dlgExit, Done);
End;

Procedure OEditSprite.Run;

Var
   ExitRepeat : Boolean;

Begin
   ExitRepeat := False;

   New(Menu, Init(260, 50, 100, VERTICAL, 'Menu', True, Pointer));
   Menu^.Add(1, True,  'Abrir');
   Menu^.Add(2, True,  'Novo');
   Menu^.Add(3, False, 'Editar');
   Menu^.Add(4, True,  'Sair');
   Menu^.Draw;

   Repeat
      Menu^.Run;
      ScreenShow;
      If (Menu^.Selected) Then
      Begin
         Case (Menu^.btClick) of
            1 : ChoseFile;
            2 : CreateNewFile;
            3 : Edit;
            4 : ExitRepeat := ExitProgram;
         End;
         Menu^.ActiveItem(3, FileName <> '');
         Menu^.Text := FileName;
         Menu^.Draw;
      End;
   Until (ExitRepeat);

   Dispose(Menu, Done);
End;


Procedure OEditSprite.Draw;

Begin
   TObject.Draw;
End;


Procedure OEditSprite.Show;

Begin
   TObject.Show;
End;

Destructor OEditSprite.Done;

Begin
   Pointer^.Done;
   TObject.Done;
   CloseGraph;
End;


{******************************************************
                  Programa Princiapal
******************************************************}

Var
   Ed : OEditSprite;
   f  : Boolean;


Begin
   f := Not ((Paramstr(1) = 'w') or (Paramstr(1) = 'W'));
   Ed.Init(f);
   Ed.Run;
   Ed.Done;
End.
