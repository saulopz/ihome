UNIT UStatus;


INTERFACE

Uses
   Graph, Crt, MyMouse, Button, Rolls, Icones,
   Boxs, TextBoxs, RollBoxs, Objects, Devices,
   Labels, Config, Strs, Collects, SysUtils;

CONST
   MAXCOUNTER_STATUS = 5;

TYPE
   PStatus = ^OStatus;
   OStatus = Object (OBox)
      icA      : OIcon;
      icB      : OIcon;
      Name     : String;
      Status   : String;
      Level1   : Byte;
      Level2   : Byte;
      Sector   : Byte;
      lbStatus : OLabel;
      lbLevel1 : OLabel;
      lbLevel2 : OLabel;
      lbSector : OLabel;
      Counter  : Byte;
      dev      : PDevice;
      oldDev   : PDevice;
      Icone    : 1..2;
      Change   : Boolean;

      Constructor Init(ix, iy : Integer; T : Boolean; tx : String; Head : Boolean; M : PMouse);
      Procedure   SetStatus(n : String; d : PDevice; sec : Byte);
      Procedure   SetIconA(ic : PIcon);
      Procedure   SetIconB(ic : PIcon);
      Procedure   Run; Virtual;
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Function    Changed : Boolean;
      Destructor  Done;
   End;

IMPLEMENTATION

Constructor OStatus.Init(ix, iy : Integer; T : Boolean; tx : String; Head : Boolean; M : PMouse);
Begin
   OBox.Init(ix, iy, 150, 155, T, tx, Head, M);
   icA.Init(X+59, Y+20, 32, 64, Pointer);
   icB.Init(X+59, Y+20, 32, 64, Pointer);
   lbStatus.Init(X+5, Y+90,  'Estado:', Pointer);
   lbLevel1.Init(X+5, Y+105, 'Nivel1:', Pointer);
   lbLevel2.Init(X+5, Y+120, 'Nivel2:', Pointer);
   lbSector.Init(X+5, Y+135, 'Setor :', Pointer);
   dev     := Nil;
   oldDev  := Nil;
   Status  := 'Desligado';
   Level1  := 0;
   Level2  := 0;
   Sector  := 0;
   Counter := 1;
   Icone   := 1;
   Change  := False;
End;

Procedure OStatus.SetStatus(n : String; d : PDevice; sec : Byte);

Var aux : String;

Begin
   If (Name <> n) Then Change := True;
   Dev    := d;
   Name   := n;
   Text   := n;
   Sector := sec;
   Str(sec, aux);
   lbSector.SetText('Setor : '+aux);
End;

Procedure OStatus.SetIconA(ic : PIcon);

Var
   i, j   : Integer;
   l, m   : Integer;
   cl, cm : Boolean;

Begin
   m  := 1;
   cm := False;
   For j := 1 To 64 Do
   Begin
      l  := 1;
      cl := False;
      For i := 1 To 32 Do
      Begin
         icA.PutPixelColor(i, j, ic^.GetPixelColor(l, m));
         If (Not cl) Then cl := True
         Else Begin
            cl := False;
            l  := l + 1;
         End;
      End;
      If (Not cm) Then cm := True
      Else Begin
         cm := False;
         m  := m + 1;
      End;
   End;
End;

Procedure OStatus.SetIconB(ic : PIcon);

Var
   i, j   : Integer;
   l, m   : Integer;
   cl, cm : Boolean;

Begin
   m  := 1;
   cm := False;
   For j := 1 To 64 Do
   Begin
      l  := 1;
      cl := False;
      For i := 1 To 32 Do
      Begin
         icB.PutPixelColor(i, j, ic^.GetPixelColor(l, m));
         If (Not cl) Then cl := True
         Else Begin
            cl := False;
            l  := l + 1;
         End;
      End;
      If (Not cm) Then cm := True
      Else Begin
         cm := False;
         m  := m + 1;
      End;
   End;
End;


Procedure OStatus.Run;

Var aux : String;

Begin
   If (Counter > MAXCOUNTER_STATUS) Then Counter := 0;
   Counter := Counter + 1;
   If (Counter = 1) Then
   Begin
      If (Icone = 1) Then
      Begin
         Icone := 2;
         icB.Draw;
      End Else Begin
         Icone := 1;
         icA.Draw;
      End;
   End;

   If (Dev <> Nil) Then
   Begin
      aux := Status;
      If (Dev^.On = 1) Then Status := 'Ligado'
      Else Status := 'Desligado';
      lbStatus.SetText('Estado: '+Status);
      If (Status <> aux) Then Change := True;
      If (Dev^.Level1 <> Level1) Then
      Begin
         Level1 := Dev^.Level1;
         Str(Level1, aux);
         lbLevel1.SetText('Nivel1: '+aux);
         Change := True;
      End;
      If (Dev^.Level2 <> Level2) Then
      Begin
         Level2 := Dev^.Level2;
         Str(Level2, aux);
         lbLevel2.SetText('Nivel2: '+aux);
         Change := True;
      End;
   End
   Else
   Begin
      lbStatus.SetText('Estado: Desligado');
      lbLevel1.SetText('Nivel1: 0');
      lbLevel2.SetText('Nivel2: 0');
   End;
   Str(Sector, aux);
   lbSector.SetText('Setor : '+aux);

   OBox.Run;
   lbStatus.Run;
   lbLevel1.Run;
   lbLevel1.Run;
   lbSector.Run;
   If (Icone = 1) Then icA.Run
   Else icB.Run;
   //ScreenShow;
End;

Procedure OStatus.Show;
Begin
   OBox.Show;
End;

Procedure OStatus.Draw;
Begin
   OBox.Draw;
   lbStatus.Draw;
   lbLevel1.Draw;
   lbLevel2.Draw;
   lbSector.Draw;
   If (Icone = 1) Then icA.Draw
   Else icB.Draw;
End;

Function OStatus.Changed : Boolean;
Begin
   Changed := Change;
   Change  := False;
End;

Destructor OStatus.Done;
Begin
   icA.Done;
   icB.Done;
   lbStatus.Done;
   lbLevel1.Done;
   lbLevel2.Done;
   lbSector.Done;
   OBox.Done;
End;

End.
