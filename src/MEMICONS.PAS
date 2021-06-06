UNIT MemIcons;


INTERFACE


USES
    Objects, MyMouse, Icones, ImgDB;


TYPE
   PMemIcon = ^OMemIcon;
   OMemIcon = Object (TObject)
      Code    : String[5];
      Level   : Byte;
      icon    : PIcon;

      Constructor Init(iCode : String; iLevel : Byte; M : PMouse);
      Procedure   PutIcon(ic : PIcon);
      Procedure   PutSprite(img : ImgSprite);
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Procedure   Free; Virtual;
      Procedure   Run; Virtual;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OMemIcon.Init(iCode : String; iLevel : Byte; M : PMouse);
Begin
   TObject.Init(0,0,0,0, M);
   Code  := iCode;
   Level := iLevel;
   icon  := nil;
End;

Procedure OMemIcon.PutIcon(ic : PIcon);
Begin
   if (icon <> nil) Then
   Begin
      Dispose(icon, Done);
      icon := Nil;
   End;
   icon := ic;
End;

Procedure OMemIcon.PutSprite(img : ImgSprite);

Var
   i, j, a : Integer;

Begin
   If (icon <> nil) Then
   Begin
      Dispose(Icon, Done);
      Icon := Nil;
   End;

   New(Icon, Init(1, 1, 16, 32, Pointer));
   a := 1;
   For j := 1 To 32 Do
      For i := 1 To 16 Do
      Begin
         Icon^.PutPixelColor(i, j, img[a]);
         a := a + 1;
      End;
End;

Procedure OMemIcon.Run;
Begin
End;

Procedure OMemIcon.Draw;
Begin
End;

Procedure OMemIcon.Show;
Begin
End;

Procedure OMemIcon.Free;
Begin
   If (icon <> Nil) Then
   Begin
      Dispose(Icon, Done);
      Icon := Nil;
   End;
End;

Destructor OMemIcon.Done;
Begin
   If (icon <> Nil) Then
      Dispose(Icon, Done);
   TObject.Done;
End;

End.