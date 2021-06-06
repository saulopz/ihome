UNIT UEditMap;


INTERFACE

Uses
   Graph, Crt, MyMouse, Button, Rolls, Boxs, TextBoxs, RollBoxs, Objects,
   Labels, Config, Collects, UMenu, ImgDb, Canvas, Icones, UDialog,
   UNewFile, UMapEd, MapDB, USecEdit, UElemSec, UElemap;

TYPE
   PEditMap = ^OEditMap;
   OEditMap = Object (OBox)
      FileName : Str12;
      btClick  : Byte;
      Menu     : OMenu;
      rbTypes  : ORollBox;
      rbSectors: ORollBox;
      icTypes  : OIcon;
      Map      : OMapEd;
      SecEdit  : OSecEdit;
      MyImgDB  : OImgDB;
      MyDirection : 0..1;
      SecEditing : Boolean;
      Safe       : Boolean;

      Constructor Init(tx : String; M : PMouse);
      Procedure   Run; Virtual;
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Procedure   InitSecEdit;
      Procedure   DoneSecEdit;
      Function    Close : Boolean;
      Function    Save : Boolean;
      Destructor  Done;
   End;

IMPLEMENTATION

Constructor OEditMap.Init(Tx : String; M : PMouse);

Var
   i       : Integer;
   MyMapDB : OMapDB;
   Reg     : MapReg;

Begin
   InitObjTypes;
   FileName    := tx;
   BtClick     := 0;
   MyDirection := 1;
   SecEditing  := False;
   Safe        := True;

   OBox.Init(1, 1, 638, 478, False, 'Edicao do Arquivo de Imagens : '+FileName, True, M);
   OBox.Draw;

   Menu.Init(1, 16, 145, HORIZONTAL, 'Menu', False, Pointer);
   Menu.Add(1, True, 'Setorizar');
   Menu.Add(2, False, 'Imagens');
   Menu.Add(3, False, 'Salvar');
   Menu.Add(4, True, 'Sair');

   rbTypes.Init(497, 55, 14, 20, 'Objetos', Pointer);
   MyMapDB.Init(FileName);
   if (MyMapDB.Get(Reg)) Then Begin
      For i := 1 To MAX_UNITS Do
         If (Reg.Element[i] <> '') Then
         Begin
            SetUnitFName(i, Reg.Element[i]);
            rbTypes.Add(GetUnitString(i));
         End;
   End;
   MyMapDB.Done;
   MyImgDB.Init(Reg.ImageFile);

   icTypes.Init(550, 400, 16, 32, Pointer);
   Map.Init(10, 60, FileName, Pointer);

   Menu.Draw;
   Map.Draw;
   rbTypes.Draw;
   icTypes.Draw;
End;

Procedure OEditMap.InitSecEdit;

Var
   i, j : Integer;
   s    : String;
   secs : SectorsMatrix;

Begin
   Map.GetSectors(secs);
   SecEdit.Init(10, 76, Pointer);
   For j := 1 To MAPHEIGHT Do
      For i := 1 To MAPWIDTH Do
         SecEdit.Grid[i,j].SetSector(secs[i,j]);
   rbSectors.Init(497, 55, 14, 20, 'Setores', Pointer);
   For i := 0 To 19 Do
   Begin
        Str(i, s);
        rbSectors.Add(s)
   End;
   SecEdit.Draw;
   rbSectors.Draw;
End;

Procedure OEditMap.DoneSecEdit;

Var
   i, j : Integer;
   secs : SectorsMatrix;

Begin
   For j := 1 To MAPHEIGHT Do
      For i := 1 To MAPWIDTH Do
         secs[i,j] := SecEdit.Grid[i,j].Sector;
   Map.SetSectors(secs);
   rbSectors.Done;
   SecEdit.Done;
   rbTypes.Draw;
   Map.Draw;
End;

Function OEditMap.Close : Boolean;

Var
   dlgExit  : PDialog;

Begin
   New(dlgExit, Init(150, 180, 305, 100, False, 'Fechar Editor', True, Pointer));
   dlgExit^.AddLine('Voce perdera as alteracoes ao fechar');
   dlgExit^.AddLine('o editor  sem  salvar.  Voce  deseja');
   dlgExit^.AddLine('continuar a operacao?');
   dlgExit^.AddButton(70, 15, 'Confirma', OK);
   dlgExit^.AddButton(70, 15, 'Cancela', CANCEL);
   dlgExit^.Draw;
   dlgExit^.Run;
   If (dlgExit^.btClick = OK) Then
      Close := True
   Else Close := False;
   dlgExit^.Clear;
   Dispose(dlgExit, Done);
End;

Function OEditMap.Save : Boolean;

Var dlg : PDialog;

Begin
   New(dlg, Init(150, 180, 315, 80, False, 'Confirmar Salvar', True, Pointer));
   dlg^.AddLine('Voce confirma a operacao para  salvar');
   dlg^.AddLine('as informacoes alteradas do seu mapa?');
   dlg^.AddButton(70, 15, 'Confirma', OK);
   dlg^.AddButton(70, 15, 'Cancela', CANCEL);
   dlg^.Draw;
   dlg^.Run;
   If (dlg^.btClick = OK) Then
      Save := True
   Else Save := False;
   dlg^.Clear;
   Dispose(dlg, Done);
End;

Procedure OEditMap.Run;

Var
   Exit    : Boolean;
   Code    : Integer;
   i, j, a : Integer;
   iSprite : ImgSprite;

Begin
   Exit := False;
   Repeat
      OBox.Run;
      Menu.Run;
      icTypes.Draw;
      ScreenShow;

      {*** Menu Object Events ***}

      If (Menu.Selected) Then
      Begin
         Case (Menu.btClick) of
            1 : Begin
                   Menu.ActiveItem(1, False);
                   Menu.ActiveItem(2, True);
                   Menu.ActiveItem(3, False);
                   Menu.ActiveItem(4, False);
                   SecEditing := True;
                   InitSecEdit;
                End;
            2 : Begin
                  Menu.ActiveItem(1, True);
                  Menu.ActiveItem(2, False);
                  Menu.ActiveItem(3, True);
                  Menu.ActiveItem(4, True);
                  SecEditing := False;
                  DoneSecEdit;
                End;
            3 : Begin
                  If (Save) Then
                  Begin
                     Map.Save;
                     Safe := True;
                  End;
                  Map.Draw;
                End;
            4 : Begin
                  If (Not Safe) Then
                  Begin
                     If (Close) Then Exit := True;
                  End Else Exit := True;
                  Map.Draw;
                End;
         End;
      End;

      If (Not SecEditing) Then
      Begin
         Map.Run;
         rbTypes.Run;

         If (Safe) Then Menu.ActiveItem(3, False)
         Else Menu.ActiveItem(3, True);

         If (Map.Selected) Then Safe := False;

         if (rbTypes.Selected) Then
         Begin
            if (rbTypes.Text = GetUnitFName(GetUnitCode(rbTypes.TextSelect))) Then
            Begin
               if (MyDirection = 0) Then MyDirection := 1
               Else MyDirection := 0;
            End
            Else
               rbTypes.Text := Map.Map.Element[GetUnitCode(rbTypes.TextSelect)];
            If (MyImgDB.Get(rbTypes.Text, MyDirection, iSprite)) Then
            Begin
               a := 1;
               For j := 1 To icTypes.Height Do
               Begin
                  For i := 1 To icTypes.Width Do
                  Begin
                     icTypes.SetPixelColor(i, j, iSprite[a]);
                     a := a+1;
                  End;
               End;
               Map.SelectElement(GetUnitCode(rbTypes.TextSelect));
               If (MyDirection = 0) Then Map.SelectedCourse := CLEFT
               Else Map.SelectedCourse := CRIGHT;
            End;
            rbTypes.Draw;
         End;
      End Else
      Begin
         SecEdit.Run;
         rbSectors.Run;

         If (SecEdit.Selected) Then Safe := False;

         If (rbSectors.Selected) Then
         Begin
            Val(rbSectors.TextSelect, SecEdit.Sector, Code);
            rbSectors.Text := 'Setor '+rbSectors.TextSelect;
            rbSectors.Draw;
            SecEdit.Draw;
         End;
      End;
   Until (Exit);
End;


Procedure OEditMap.Show;
Begin
   OBox.Show;
End;

Procedure OEditMap.Draw;
Begin
   icTypes.Draw;
   Menu.Draw;
   If (SecEditing) Then
   Begin
      SecEdit.Draw;
      rbSectors.Draw;
   End
   Else
   Begin
      rbTypes.Draw;
      Map.Draw;
   End;
End;

Destructor OEditMap.Done;
Begin
   rbTypes.Done;
   icTypes.Done;
   MyImgDB.Done;
   Map.Done;
   Menu.Done;
   OBox.Done;
End;

End.