Program IHome;

uses
  Graph,
  Crt,
  MyMouse,
  Objects,
  UGetFile,
  UDialog,
  Button,
  UMenu,
  MapDB,
  ImgDB,
  URunMap,
  SysUtils,
  UElemSec,
  Config,
  UMapObj in 'UMapObj.pas',
  UEleUser in 'UEleUser.pas',
  USectors in 'USectors.pas',
  UShell in 'UShell.pas',
  Search in 'Search.pas';

TYPE

   {*** Class OEditHomeMap ***}

   OIHome = Object (TObject)
      FileName  : String;
      FileImage : String;
      Menu      : PMenu;

      Constructor Init(fullscreen : Boolean);
      Procedure   ChoseFile;
      Function    ExitProgram : Boolean;
      Procedure   Execute;
      Procedure   Run;  Virtual;
      Procedure   Draw; Virtual;
      Procedure   Show; Virtual;
      Destructor  Done;
   End;


{***************************************************

   Implementation of Object OEditHomeMap Methods

***************************************************}

Constructor OIHome.Init(fullscreen : Boolean);

Var
   Start : PDialog;

Begin
   InitGraph('EdHMap', fullscreen);

   New(Pointer, Init);
   TObject.Init(1, 1, 1, 1, Pointer);

   FileName  := '';
   FileImage := '';

   New(Start, Init(145, 80, 310, 270, False, 'Casa Inteligente', True, Pointer));
   Start^.AddLine('Prototipo para simulacao de uma casa');
   Start^.AddLine('inteligente utilizando a tecnica  de');
   Start^.AddLine('Inteligencia Artificial Distribuida.');
   Start^.AddLine('');
   Start^.AddLine('Baseado na dissertacao  de  mestrado');
   Start^.AddLine('sobre Ambientes Inteligentes.');
   Start^.AddLine('');
   Start^.AddLine('Mestrando:');
   Start^.AddLine('   Saulo Popov Zambiasi.');
   Start^.AddLine('Orientadores:');
   Start^.AddLine('   Luiz Fernando Jascinto Maia.');
   Start^.AddLine('   Joao Bosco da Mota Alves.');
   Start^.AddLine('Versao:');
   Start^.AddLine('   10.08.2002');
   Start^.AddButton(70, 15, 'Iniciar', OK);
   Start^.Draw;

   Pointer^.Show(True);

   Start^.Run;
   Dispose(Start, Done);
   ClrScreen;
End;

Procedure OIHome.ChoseFile;

Var
   GetFile : PGetFile;

Begin
   New(GetFile, Init(220, 100, 10, 'Arquivo de Mapa','*.HMP', Pointer));
   GetFile^.Run;
   If (GetFile^.btClick = OK) Then FileName := GetFile^.FileName;
   Dispose(GetFile, Done);
   ClrScreen;
End;

Procedure OIHome.Execute;

Var
   RunMAP : PRunMAP;

Begin
   New(RunMAP, Init(FileName, Pointer));
   RunMAP^.Run;
   Dispose(RunMAP, Done);
   ClrScreen;
End;

Function OIHome.ExitProgram : Boolean;

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

Procedure OIHome.Run;

Var
   Exit  : Boolean;

Begin
   Exit := False;

   New(Menu, Init(260, 50, 100, VERTICAL, 'Menu', True, Pointer));
   Menu^.Add(1, True,  'Abrir');
   Menu^.Add(2, False, 'Executar');
   Menu^.Add(3, True,  'Sair');
   Menu^.Draw;

   Repeat
      Menu^.Run;
      ScreenShow;
      If (Menu^.Selected) Then
      Begin
         Case (Menu^.btClick) of
            1 : ChoseFile;
            2 : Execute;
            3 : Exit := ExitProgram;
         End;
         Menu^.ActiveItem(2, FileName <> '');
         Menu^.Text := FileName;
         Menu^.Draw;
      End;

   Until (Exit);

   Dispose(Menu, Done);
End;


Procedure OIHome.Draw;

Begin
   TObject.Draw;
End;


Procedure OIHome.Show;

Begin
   TObject.Show;
End;

Destructor OIHome.Done;

Begin
   Pointer^.Done;
   TObject.Done;
   CloseGraph;
End;


{******************************************************

                  Programa Princiapal

******************************************************}

Var
   Ed : OIHome;
   f  : Boolean;

Begin
   f := Not ((Paramstr(1) = 'w') or (Paramstr(1) = 'W'));
   Ed.Init(f);
   Ed.Run;
   Ed.Done;
End.