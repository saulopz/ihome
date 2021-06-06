UNIT Canvas;


INTERFACE

USES
   Objects, MyMouse, Graph, Collects, Rolls, Strs, Button, Config, DrPixels;

TYPE
   PCanvas = ^OCanvas;
   OCanvas = Object (TObject)
      Text        : String;
      Select      : Boolean;
      SizeWidth   : Byte;
      SizeHeight  : Byte;
      Pix         : OCollection;
      CanvasColor : Byte;

      Constructor Init(ix, iy, w, h, pixsize : Integer; Tx : String; M : PMouse);
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Procedure   Run; Virtual;
      Procedure   SetPixelColor(ix, iy, c : Byte);
      Function    GetPixelColor(ix, iy : Byte) : Byte;
      Function    Selected : Boolean;
      Function    GetCanvasColor : Byte;
      Procedure   SetCanvasColor(c : Byte);
      Procedure   SetPixelBorder(on : Boolean);
      Procedure   Clear; Virtual;
      Destructor  Done;
   End;

IMPLEMENTATION

Constructor OCanvas.Init(ix, iy, w, h, pixsize : Integer; Tx : String; M : PMouse);

Var
   i, j  : Integer;
   pxaux : PDrawPixel;

Begin
   SizeWidth := w;
   SizeHeight:= h;


   TObject.Init(ix, iy, (w*pixsize)+2, (h*pixsize)+17, M);
   Pix.Init;

   Text      := Tx;
   Select    := False;

   CanvasColor := 0;

   For j := 1 To h Do
   Begin
      For i := 1 To w Do
      Begin
         New(pxaux, Init(x+1+(pixsize*i)-pixsize, y+16+(pixsize*j)-pixsize, pixsize, pixsize, 0, M));
         Pix.InsertItem(pxaux);
      End;
   End;
End;

Procedure OCanvas.Draw;

Var
   tx, i : Integer;
   txaux : String;
   size  : Integer;

Begin
   SetColor(Border);
   Line(x, y, x+Width, y);
   Line(x, y+Height, x+Width, y+Height);
   Line(x, y+1, x, y+Height-1);
   Line(x+Width, y+1, x+Width, y+Height-1);
   Line(x+1, y+15, x+Width-1, y+15);
   Line(x+Width-15, y+1, x+Width-15, y+14);

   If (InRange) Then SetColor(Backon)
   Else SetColor(Backoff);

   For i := y+1 To y+14 Do
      Line(x+1, i, x+Width-16, i);

   SetColor(CanvasColor);
   For i := y+1 To y+14 Do
      Line(x+Width-14, i, x+Width-1, i);

   Size := Length(Text);
   // i := y + (((y+Height - y) div 2) - 3);

   Case (Align) of
      LEFT   : tx := x + 2;
      RIGHT  : tx := (x+Width - 2) - Size*8;
      CENTER : tx := x + ((Width-16) Div 2) - ((Size*8) Div 2);
      else tx := x + 2;
   End;

   SetColor(TxColor);

   If (Length(Text)*8 > Width-17) Then
      txaux := Copy(Text, 1, ((Width-2) Div 8))
   Else txaux := Text;

   OutTextXY(tx, y+4, txaux);

   Pix.Draw;
End;

Procedure OCanvas.SetCanvasColor(c : Byte);

Var
   i     : Integer;
   pxaux : PDrawPixel;

Begin
   CanvasColor := c;
   For i := 1 To Pix.GetSize Do
   Begin
      pxaux := Pix.GetItem(i);
      pxaux^.SetNewColor(c);
   End;
   Draw;
End;

Function OCanvas.GetCanvasColor : Byte;
Begin
   GetCanvasColor := CanvasColor;
End;

Procedure OCanvas.SetPixelColor(ix, iy, c : Byte);

Var
   pxaux : PDrawPixel;

Begin
   if (((ix*iy) <= (SizeWidth*SizeHeight)) and (c<16)) Then
   Begin
      pxaux := Pix.GetItem(((iy-1)*SizeWidth) + ix);
      pxaux^.Value := c;
      pxaux^.Draw;
   End;
End;


Function OCanvas.GetPixelColor(ix, iy : Byte) : Byte;

Var
   pxaux : PDrawPixel;

Begin
   if ((ix*iy) <= (SizeWidth*SizeHeight)) Then
   Begin
      pxaux := Pix.GetItem(((iy-1)*SizeWidth) + ix);
      GetPixelColor := pxaux^.Value;
   End Else GetPixelColor := 0;
End;

Procedure OCanvas.SetPixelBorder(on : Boolean);

Var
   pxaux : PDrawPixel;
   i     : Integer;

Begin
   For i := 1 To Pix.GetSize Do
   Begin
      pxaux := Pix.GetItem(i);
      pxaux^.SetBorder(on);
      pxaux^.Draw;
   End;
End;

Procedure OCanvas.Clear;

Var
   i     : Integer;
   pxaux : PDrawPixel;

Begin
   For i := 1 To (SizeWidth*SizeHeight) Do
   Begin
      pxaux := Pix.GetItem(i);
      pxaux^.Clear;
   End;
End;

Procedure OCanvas.Show;
Begin
   TObject.Show;
End;


Procedure OCanvas.Run;

Var
  pxaux : PDrawPixel;
  i     : Integer;

Begin
   If (Visible) Then Show;

   If (InRange) Then
   Begin
      For i := 1 To Pix.GetSize Do
      Begin
         pxaux := Pix.GetItem(i);
         pxaux^.Run;
         if (pxaux^.Selected) Then Select := True;
      End;
   End;
End;

Function OCanvas.Selected : Boolean;

Begin
   Selected   := Select;
   Select     := False;
End;

Destructor OCanvas.Done;

Begin
   Pix.Done;
   TObject.Done;
End;

End.
