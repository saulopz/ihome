UNIT UEleMap;

INTERFACE

USES
   Graph, Mouse, Objects, Collects, Icones,
   Config, MapDB, Devices, Agents, SystemMS;

TYPE
   PElement = ^OElement;
   OElement = Object (TObject)
      on     : Boolean;
      Step   : 0..1;
      icList : OCollection;
      Size   : Byte;
      Sector : Byte;
      Course : SetofCourse;
      icVoid : PIcon;
      Dev    : PDevice;
      MyAgent: PAgent;

      Constructor Init(ix, iy, w, h : Integer; Ms, agType, id : Byte; icv : PIcon; M : PMouse);
      Procedure   PutIcon(ic : PIcon);
      Procedure   Draw; Virtual;
      Procedure   Show; Virtual;
      Procedure   Run; Virtual;
      Destructor  Done;
   End;


IMPLEMENTATION

Constructor OElement.Init(ix, iy, w, h : Integer; MS, agType, id : Byte; icv : PIcon; M : PMouse);

Var
   i : Byte;


Begin
   TObject.Init(ix, iy, w, h, M);
   icList.Init;
   icList.SetFree(False);
   icVoid := icv;

{   Ver o TIPO de agente e inicializar conforme o tipo }

{   New(MyAgent, Init(MS, agType, id, Dev));}
   Size := 0;
   Step := 0;
End;

Procedure OElement.PutIcon(ic : PIcon);
Begin
   icList.InsertItem(ic);
End;

Procedure OElement.Show;
Begin
   TObject.Show;
End;

Procedure OElement.Draw;

Var
   i  : Byte;
   ic : PIcon;

Begin
   { If is on }
   if (Not on) Then i := 0
   Else i := 2+(Step*2);

   { if your course is to right }
   If ((Course = CWRIGHTDOWN) or
       (Course = CWRIGHTUP)   or
       (Course = CWRIGHT))    Then
      i := i+1;

   { if has a icon to put }
   If (icList.GetSize < i) Then
      If ((i-2) >= 0) Then i := i-2;

   { put icon }
   If (icList.GetSize >= i) Then
   Begin
      ic := icList.GetItem(i);
      ic^.X := X;
      ic^.Y := Y-ELEMENTWIDTH;
      ic^.Draw;
   End Else
   Begin
      icVoid^.X := X;
      icVoid^.Y := Y-ELEMENTWIDTH;
      icVoid^.Draw;
   End;
End;

Procedure OElement.Run;
Begin
End;

Destructor OElement.Done;
Begin
   icList.Done;
   TObject.Done;
End;

End.