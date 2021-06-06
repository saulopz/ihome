UNIT UEleUser;

INTERFACE

USES
   Graph, MyMouse, Objects, Collects, Icones,
   Config, MapDB, ImgDB, Devices, Agents,
   UElemap, SystemMS, UMapObj, UEleMapX;

CONST
   USER_STEP_COUNTER = 1;

TYPE
   PElementUser = ^OElementUser;
   OElementUser = Object (OElementX)
      NextX   : Integer;
      NextY   : Integer;
      AuxCount: Integer;
      MyStep  : Byte;
      ListA   : Array[0..7] of PIcon;
      ListB   : Array[0..7] of PIcon;
      ListC   : Array[0..7] of PIcon;
      Constructor Init(ix, iy, w, h : Integer; t : Byte; icv : PIcon; M : PMouse);
      Procedure   Draw; Virtual;
      Procedure   DrawBorder; Virtual;
      Procedure   Show; Virtual;
      Procedure   Walk;
      Function    FreeWay(xa, ya, xb, yb : Byte) : Boolean;
      Procedure   Run; Virtual;
      Procedure   SetUserIcon(s : Char; ic : PIcon; l : Byte);
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OElementUser.Init(ix, iy, w, h : Integer; t : Byte; icv : PIcon; M : PMouse);
Begin
   OElement.Init(ix, iy, w, h, t, icv, M);
   MyStep  := 0;
   NextX   := MyX;
   NextY   := MyY;
   Course  := CDOWN;
   AuxCount:= 0;
End;

Procedure OElementUser.SetUserIcon(s : Char; ic : PIcon; l : Byte);
Begin
   if (s = 'a') Then ListA[l] := ic
   else if (s = 'b') Then ListB[l] := ic
   else ListC[l] := ic;
End;

Procedure OElementUser.Show;
Begin
   OElementX.Show;
End;

Procedure OElementUser.DrawBorder;
Begin
   OElementX.DrawBorder;
End;

Procedure OElementUser.Draw;

Var i : Byte;

Begin
   Case (Course) of
      CDOWN       : i := 0;
      CUP         : i := 1;
      CLEFT       : i := 2;
      CRIGHT      : i := 3;
      CLEFTDOWN   : i := 4;
      CRIGHTDOWN  : i := 5;
      CLEFTUP     : i := 6;
      CRIGHTUP    : i := 7;
      Else          i := 0;
   End;

   If ((ListA[i] = Nil) or (ListB[i] = Nil) or (ListC[i] = Nil)) Then
   Begin
     icVoid^.X := X;
     icVoid^.Y := Y {- ElementUserWIDTH};
     icVoid^.Draw;
   End
   Else
   Begin
      If (Step = 0) Then
      Begin
         ListA[i]^.X := X;
         ListA[i]^.Y := Y {- ElementUserWIDTH};
         ListA[i]^.Draw;
      End
      Else If ((Step = 1) and (MyStep = 0)) Then
      Begin
         ListB[i]^.X := X;
         ListB[i]^.Y := Y {- ElementUserWIDTH};
         ListB[i]^.Draw;
      End
      Else
      Begin
         ListC[i]^.X := X;
         ListC[i]^.Y := Y {- ElementUserWIDTH};
         ListC[i]^.Draw;
      End;
   End;
End;

Procedure OElementUser.Run;

Var  bx, by, bb : Integer;

Begin
   If (Visible) Then Show;

   If (Active and InRange) Then
   Begin
      If (Pointer^.Press) Then
      Begin
         Pointer^.Status(bx, by, bb);
         If (Not Pressed) Then
            If (bb = 4) Then
            Begin
               Pressed := True;
               Select  := True;
            End;
      End Else Pressed := False;
   End Else Pressed := False;
   Walk;
End;

Procedure OElementUser.Walk;
Begin
   If (Go) Then
   Begin
      If ((MyX = GoX) and (MyY = GoY)) Then Go := False
      Else Begin
         If (Walking) Then
         Begin
            If ((X = Map[NextX, NextY].X) and (Y = Map[NextX,  NextY].Y)) Then
            Begin
               Walking := False;
               MyX := NextX;
               MyY := NextY;
            End;
            If (NextX > MyX) Then X := X+8
            Else If (NextX < MyX) Then X := X-8;
            If (NextY > MyY) Then Y := Y+8
            Else If (NextY < MyY) Then Y := Y-8;

            If (Step = 0) Then Step := 1
            Else Step := 0;
         End Else
         Begin
            If (GoX > MyX) Then NextX := MyX+1
            Else If (GoX < MyX) Then NextX := MyX-1
            Else NextX := MyX;
            If (GoY > MyY) Then NextY := MyY+1
            Else If (GoY < MyY) Then NextY := MyY-1
            Else NextY := MyY;

            If (NextY < MyY) Then
            Begin
               If (NextX < MyX) Then
               Begin
                  If (Not FreeWay(MyX-1, MyY, MyX, MyY-1)) Then Go := False;
                  Course := CLEFTUP;
               End
               Else If (NextX > MyX) Then
               Begin
                  If (Not FreeWay(MyX+1, MyY, MyX, MyY-1)) Then Go := False;
                  Course := CRIGHTUP
               End Else Course := CUP
            End
            Else If (NextY > MyY) Then
            Begin
               If (NextX < MyX) Then
               Begin
                  If (Not FreeWay(MyX-1, MyY, MyX, MyY+1)) Then Go := False;
                  Course := CLEFTDOWN;
               End
               Else If (NextX > MyX) Then
               Begin
                  If (Not FreeWay(MyX+1, MyY, MyX, MyY+1)) Then Go := False;
                  Course := CRIGHTDOWN;
               End Else Course := CDOWN;
            End
            Else Begin
               if (NextX > MyX) Then Course := CRIGHT
               Else Course := CLEFT;
            End;
            If (Not FreeWay(NextX, NextY, NextX, NextY)) Then Go := False
            Else Walking := True;
            If (Go = False) Then
            Begin
               NextX := MyX;
               NextY := MyY;
            End;
         End;
      End;
      If (Step = 1) Then
      Begin
         If (MyStep = 0) Then MyStep := 1
         Else MyStep := 0;
      End;
   End Else Step := 0;
   If (Not Walking) Then Step := 0;
End;

Function OElementUser.FreeWay(xa, ya, xb, yb : Byte) : Boolean;

Var
   isFree   : Boolean;
   onA, onB : Boolean;

Begin
   isFree := True;
   If ((Map[xa, ya]^.Code <> GetUnitFName(UNIT_FLOOR)) and
       (Map[xb, yb]^.Code <> GetUnitFName(UNIT_FLOOR))) Then
   Begin
      If (Map[xa, ya]^.Code = GetUnitFName(UNIT_DOOR)) Then
      Begin
         If (Map[xa, ya]^.Dev <> Nil) Then onA := Boolean(Map[xa, ya]^.Dev.On)
         Else onA := False;
      End Else OnA := False;
      If (Map[xb, yb]^.Code = GetUnitFName(UNIT_DOOR)) Then
      Begin
         If (Map[xb, yb]^.Dev <> Nil) Then onB := Boolean(Map[xb, yb]^.Dev.On)
         Else onB := False;
      End else OnB := False;
      If ((Not onA) and (Not onB)) Then isFree := False;
   End;
   FreeWay := isFree;
End;

Destructor OElementUser.Done;
Begin
   OElementX.Done;
End;

End.
