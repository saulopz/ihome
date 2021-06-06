UNIT Icones;


INTERFACE

USES
   Objects, MyMouse, Graph, Config;

TYPE

   PPixel = ^RPixel;
   RPixel = Record
      X, Y    : Integer;
      Value   : Byte;
      ColorGr : Byte;
      Next    : PPixel;
   End;

   PIcon = ^OIcon;
   OIcon = Object (TObject)
      Select  : Boolean;
      Pressed : Boolean;

      First   : PPixel;
      Point   : PPixel;
      Last    : PPixel;
      Size    : Integer;
      Back    : Boolean;

      Constructor Init(ix, iy, w, h : Integer; M : PMouse);
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Procedure   OverDraw;
      Procedure   Run; Virtual;
      Procedure   Clear;
      Procedure   SetPixelColor(ix, iy : Integer; c : Byte);
      Procedure   PutPixelColor(ix, iy : Integer; c : Byte);
      Procedure   SetVisible(on : Boolean);
      Procedure   Copy(ic : PIcon);
      Procedure   AddItem(ix, iy: Integer; v : Byte);
      Function    GetItem(ix, iy : Integer) : PPixel;

      Function    GetPixelColor(ix, iy : Integer) : Byte;
      Function    Selected : Boolean;
      Destructor  Done;
   End;

IMPLEMENTATION

Constructor OIcon.Init(ix, iy, w, h : Integer; M : PMouse);

Var
   i, j  : Integer;

Begin
   TObject.Init(ix, iy, w, h, M);

   First   := Nil;
   Point   := Nil;
   Last    := Nil;
   Size    := 0;
   Back    := True;

   Select  := False;
   Pressed := False;

   For j := 0 To Height-1 Do
      For i := 0 To Width-1 Do
         AddItem(i, j, 0);
End;

Procedure OIcon.AddItem(ix, iy : Integer; v : Byte);
Begin
   Inc(Size);
   New(Point);
   Point^.X       := ix;
   Point^.Y       := iy;
   Point^.Value   := v;
   Point^.ColorGr := GetPixel(X+ix, Y+iy);
   Point^.Next    := Nil;

   If (First = Nil) Then
   Begin
      First := Point;
      Last  := First;
   End Else
   Begin
      Last^.Next := Point;
      Last := Point;
   End;
End;

Procedure OIcon.Draw;

Var
   pxaux : PPixel;

Begin
//   Pointer^.Show(False);

   pxaux := First;
   While (pxaux <> Nil) Do
   Begin
      If ((pxaux^.Value <> 0) and Visible) Then
         PutPixel(X+pxaux^.X, Y+pxaux^.Y, pxaux^.Value)
      Else If (Back) Then
         PutPixel(X+pxaux^.X, Y+pxaux^.Y, pxaux^.ColorGr);

      pxaux := pxaux^.Next;
   End;

//   Pointer^.Show(True);
End;

Procedure OIcon.OverDraw;

Var
   pxaux : PPixel;
   i     : Integer;

Begin
//   Pointer^.Show(False);
   pxaux := First;
   i := 0;
   While ((pxaux <> Nil) and (i<256)) Do
   Begin
      If ((pxaux^.Value <> 0) and Visible) Then
         PutPixel(X+pxaux^.X, Y+pxaux^.Y, pxaux^.Value)
      Else If (Back) Then
         PutPixel(X+pxaux^.X, Y+pxaux^.Y, pxaux^.ColorGr);
      pxaux := pxaux^.Next;
      i := i+1;
   End;
//   Pointer^.Show(True);
End;


Procedure OIcon.SetVisible(on : Boolean);
Begin
   Visible := on;
   Draw;
End;

Function OIcon.GetItem(ix, iy : Integer) : PPixel;

Var
   pxaux     : PPixel;
   i, j      : Integer;
   ExitWhile : Boolean;

Begin
   j := ((iy-1)*Width) + ix;
   ExitWhile := False;
   i    := 1;
   pxaux := First;
   While (Not ExitWhile) Do
   Begin
      If (pxaux <> Nil) Then
      Begin
         If (i = j) Then ExitWhile := True
         Else pxaux := pxaux^.Next;
      End Else ExitWhile := True;
      inc(i);
   End;
   GetItem := pxaux;
End;

Procedure OIcon.SetPixelColor(ix, iy : Integer; c : Byte);

Var
   pxaux : PPixel;

Begin
   if ((ix <= Width) and (iy <= Height) or (c < 16)) Then
   Begin
      pxaux := GetItem(ix, iy);
      pxaux^.Value := c;

      If ((pxaux^.Value <> 0) and Visible) Then
         PutPixel(X+pxaux^.X, Y+pxaux^.Y, pxaux^.Value)
      Else PutPixel(X+pxaux^.X, Y+pxaux^.Y, pxaux^.ColorGr);
   End;
End;

Procedure OIcon.PutPixelColor(ix, iy : Integer; c : Byte);

Var
   pxaux : PPixel;

Begin
   if ((ix <= Width) and (iy <= Height) or (c < 16)) Then
   Begin
      pxaux := GetItem(ix, iy);
      pxaux^.Value := c;
   End;
End;

Function OIcon.GetPixelColor(ix, iy : Integer) : Byte;

Var
   pxaux : PPixel;

Begin
   if ((ix <= Width) and (iy <= Height)) Then
   Begin
      pxaux := GetItem(ix, iy);
      GetPixelColor := pxaux^.Value;
   End Else GetPixelColor := 0;
End;

Procedure OIcon.Copy(ic : PIcon);

Var
   mypix : PPixel;
   cppix : PPixel;

Begin
   If ((Width = ic^.Width) and (Height = ic^.Height)) Then
   Begin
      mypix := First;
      cppix := ic^.First;
      While (mypix <> Nil) Do
      Begin
         mypix^.Value := cppix^.Value;
         mypix := mypix^.Next;
         cppix := cppix^.Next;
      End;
   End;
End;

Procedure OIcon.Show;
Begin
   TObject.Show;
End;

Procedure OIcon.Clear;

Var
   pxaux : PPixel;

Begin
   pxaux := First;
   While (pxaux <> Nil) Do
   Begin
      pxaux^.Value := pxaux^.ColorGr;
      pxaux := pxaux^.Next;
   End;
   Draw;
End;

Procedure OIcon.Run;
Begin
   If (Visible) Then Show;

   If (InRange) Then
   Begin
      If (Pointer^.Press) Then
      Begin
         If (Not Pressed) Then
         Begin
            Pressed := True;
            Select  := True;
         End
      End Else Pressed := False;
   End Else Pressed := False;
End;

Function OIcon.Selected : Boolean;

Begin
   Selected   := Select;
   Select     := False;
End;

Destructor OIcon.Done;

Begin
   While (First <> Nil) Do
   Begin
      Point := First;
      First := First^.Next;
      Dispose(Point);
   End;
   TObject.Done;
End;

End.
