UNIT Objects;

INTERFACE

Uses
   MyMouse, Graph, Config;

TYPE
   PObject = ^TObject;
   TObject = Object
      X, Y      : Integer;
      Width     : Integer;
      Height    : Integer;
      Border    : Byte;
      Backoff   : Byte;
      Backon    : Byte;
      Backgr    : Byte;
      TxColor   : Byte;
      Pointer   : PMouse;
      MouseOver : Boolean;
      Align     : Alignation;
      Visible   : Boolean;
      Active    : Boolean;

      Constructor Init(ix, iy, w, h : Integer; M : PMouse);
      Procedure   Run;  Virtual;
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Procedure   ClrScreen;
      Function    InRange : Boolean;
      Destructor  Done;
   End;

IMPLEMENTATION

Constructor TObject.Init(ix, iy, w, h : Integer; M : PMouse);
Begin
   X         := ix;
   Y         := iy;
   Width     := w;
   Height    := h;
   Pointer   := M;
   Border    := COLOR_BORDER;
   Backoff   := COLOR_BACKOFF;
   Backon    := COLOR_BACKON;
   Backgr    := COLOR_BACKGR;
   TxColor   := COLOR_TEXT;
   Align     := GENERAL_ALIGN;
   MouseOver := False;
   Visible   := True;
   Active    := True;
End;

Procedure TObject.Run;
Begin
End;

Procedure TObject.Draw;
Begin
End;

Function TObject.InRange : Boolean;

Var
   mx, my, mb : Integer;

Begin
   Pointer^.Status(mx, my, mb);
   InRange := (mx >= x) and (mx <= x+Width) and
              (my >= y) and (my <= y+Height);
End;

Procedure TObject.Show;

Begin
   If (InRange) Then
   Begin
      If (Not MouseOver) Then
      Begin
         Pointer^.Show(False);
         Draw;
         Pointer^.Show(True);
      End;
      MouseOver := True;
   End
   Else Begin
      If (MouseOver) Then
      Begin
         Pointer^.Show(False);
         Draw;
         Pointer^.Show(True);
      End;
      MouseOver := False;
   End;
End;

Destructor TObject.Done;
Begin
End;

Procedure TObject.ClrScreen;
Begin
   Pointer^.Show(False);
   SetBkColor(0);
   ClearDevice;
   Pointer^.Show(True);
End;

End.
