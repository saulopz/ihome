UNIT Strs;

INTERFACE


TYPE

   PNStr = ^NStr;
   NStr  = Record
      Next : PNstr;
      Item : String;
   End;


   PStr = ^OStr;
   OStr = Object
   Private
      Size  : Integer;
      First : PNStr;
      Select: PNStr;
   Public
       Constructor Init;
       Procedure   Add(tx : String);
       Function    Get(index : Integer) : String;
       Function    GetSize : Integer;
       Procedure   Free; Virtual;
       Destructor  Done;
   End;


IMPLEMENTATION


Constructor OStr.Init;
Begin
   First  := Nil;
   Select := Nil;
   Size   := 0;
End;

Procedure OStr.Add(tx : String);

Var
  Pont : PNStr;
  Prev : PNStr;
  Vazio: Boolean;

Begin
   Inc(Size);
   Vazio := True;
   Pont  := First;
   Prev  := Pont;
   While Pont <> Nil Do
   Begin
      Prev := Pont;
      Pont := Pont^.Next;
      Vazio:= False;
   End;
   New(Pont);
   Pont^.Item := tx;
   Pont^.Next := Nil;
   If Not Vazio Then
      Prev^.Next := Pont
   Else
   Begin
      First := Pont;
      Select := First;
   End;
End;


Function OStr.Get(index : Integer) : String;

Var
   Pont : PNStr;
   item : String;
   i    : Integer;

Begin
   Item := 'NULL';
   Pont:= First;
   i   := 1;
   While (i <= Index) and (Pont <> Nil) Do
   Begin
      If i = Index Then
         Item := Pont^.Item;
      Pont := Pont^.Next;
      Inc(i);
   End;
   Get := Item;
End;

Function OStr.GetSize : Integer;
Begin
   GetSize := Size;
End;

Procedure OStr.Free;

Var
   Pont : PNStr;

Begin
   Size := 0;
   While (First <> Nil) Do
   Begin
      Pont := First;
      First := First^.Next;
      Dispose(Pont);
   End;
End;


Destructor OStr.Done;

Var
   Pont : PNStr;

Begin
   While (First <> Nil) Do
   Begin
      Pont := First;
      First := First^.Next;
      Dispose(Pont);
   End;
End;

End.