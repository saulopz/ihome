{**********************************************

       File : mouse.pas
 Developper : Saulo Popov Zambiasi
Last Update : Feb/09/2002

**********************************************}

UNIT MyMouse;

INTERFACE

USES
   alpgraph, ag_sdl;

TYPE
   PMouse = ^OMouse;
   OMouse = Object
      Constructor Init;
      Function    Press : Boolean;
      Procedure   Status(var x, y, b : Integer);
      Procedure   Show(i : Boolean);
      Procedure   MyCursor(c : Byte);
      Procedure   Draw;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OMouse.Init;
Begin
   ShowMouse;
End;

Procedure OMouse.MyCursor(c : Byte);
Begin
   if (c = 0) Then SetMouseCursor(nil, nil);
End;

Procedure OMouse.Show(i : Boolean);
Begin
   if (i) Then ShowMouse
   Else HideMouse;
End;

Procedure OMouse.Draw;
Begin
End;

Procedure OMouse.Status(var x, y, b : Integer);
Begin
  idle;
  x := ag_mousex;
  y := ag_mousey;
  b := ag_mouseb;
End;


Function OMouse.Press : Boolean;

Var b, x, y : Integer;

Begin
   Status(x, y, b);
   Press := b <> 0;
End;

Destructor OMouse.Done;
Begin
   HideMouse;
End;

End.
