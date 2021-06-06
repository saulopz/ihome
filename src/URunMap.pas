UNIT URunMap;


INTERFACE

Uses
   Graph, Crt, MyMouse, Button, Rolls, Boxs, TextBoxs, RollBoxs,
   Objects, Labels, Config, Collects, UMenu, ImgDb, Canvas, Icones,
   UDialog, UNewFile, UMapX, MapDB, USecEdit, UElemSec, UElemap,
   RollText, UStatus;

TYPE
   PRunMap = ^ORunMap;
   ORunMap = Object (OBox)
      FileName : Str12;
      btExit   : OButton;
      rlText   : ORollText;
      Map      : OMapX;
      MyImgDB  : OImgDB;
      Status   : OStatus;

      Constructor Init(tx : String; M : PMouse);
      Procedure   Run; Virtual;
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Destructor  Done;
   End;

IMPLEMENTATION

Constructor ORunMap.Init(Tx : String; M : PMouse);

Var
   i       : Integer;
   MyMapDB : OMapDB;
   Reg     : MapReg;

Begin
   InitObjTypes;
   FileName := tx;

   OBox.Init(1, 1, 638, 478, False, 'Casa Inteligente - Execucao do Mapa: '+FileName, True, M);
   OBox.Draw;

   btExit.Init(565, 460, 70, 16, 'Sair', Pointer);
   btExit.Draw;

   rlText.Init(5, 365, 57, 5, 'Linha de Comando', Pointer);
   rlText.Draw;

   MyMapDB.Init(FileName);
   if (MyMapDB.Get(Reg)) Then Begin
      For i := 1 To MAX_UNITS Do
         If (Reg.Element[i] <> '') Then
            SetUnitFName(i, Reg.Element[i]);
   End;
   MyMapDB.Done;

   Map.Init(5, 20, FileName, Pointer);
   Map.Draw;

   Status.Init(487, 20, False, 'Status', True, Pointer);
   Status.Draw;

   MyImgDB.Init(Reg.ImageFile);
End;

Procedure ORunMap.Run;

Var
   Exit     : Boolean;
   myName   : String;
   mySector : Byte;
   cmdReturn: String;


Begin
   Exit := False;
   Repeat
      OBox.Run;
      btExit.Run;
      rlText.Run;
      Status.Run;
      Map.Run;

      // Show all on the screen - That is very important
      ScreenShow;

      If (rlText.Selected) Then
      Begin
         cmdReturn := Map.Command(StringUpper(rlText.TextSelect));
         If (cmdReturn = 'EXIT') Then Exit := True
         Else If (cmdReturn <> 'NULL') Then
         Begin
            rlText.Add(cmdReturn);
            rlText.EOL;
            rlText.Draw;
         End;
      End;

      If (btExit.Selected) Then Exit := True;

      if (Map.ChangeObject) Then
      Begin
          myName := GetUnitString(GetUnitFCode(Map.Grid[Map.SelectedX, Map.SelectedY]^.Code));
          If (Map.Grid[Map.SelectedX, Map.SelectedY]^.Dev <> Nil) Then
          Begin
             if (Map.Grid[Map.SelectedX, Map.SelectedY]^.Dev^.On = 1) Then
             Begin
                Status.SetIconA(Map.Grid[Map.SelectedX, Map.SelectedY]^.ListIcons[2]);
                Status.SetIconB(Map.Grid[Map.SelectedX, Map.SelectedY]^.ListIcons[4]);
             End Else Begin
                Status.SetIconA(Map.Grid[Map.SelectedX, Map.SelectedY]^.ListIcons[0]);
                Status.SetIconB(Map.Grid[Map.SelectedX, Map.SelectedY]^.ListIcons[0]);
             End;
          End Else Begin
             Status.SetIconA(Map.Grid[Map.SelectedX, Map.SelectedY]^.ListIcons[0]);
             Status.SetIconB(Map.Grid[Map.SelectedX, Map.SelectedY]^.ListIcons[0]);
          End;
          mySector := Map.Grid[Map.SelectedX, Map.SelectedY]^.Sector;
          Status.SetStatus(myName, Map.Grid[Map.SelectedX, Map.SelectedY]^.Dev, mySector);
          Status.Draw;
      End;
      If (Status.Changed) Then Status.Draw;
   Until (Exit);
End;


Procedure ORunMap.Show;
Begin
   OBox.Show;
End;

Procedure ORunMap.Draw;
Begin
   OBox.Draw;
   btExit.Draw;
   rlText.Draw;
   Status.Draw;
   Map.Draw;
End;

Destructor ORunMap.Done;
Begin
   MyImgDB.Done;
   btExit.Done;
   rlText.Done;
   Status.Done;
   Map.Done;
   OBox.Done;
End;

End.