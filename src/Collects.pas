UNIT Collects;

INTERFACE

USES
   Crt, Objects;

TYPE
   PNodo = ^Nodo;
   Nodo = Record
      Next : PNodo;
      Item : PObject;
   End;
   PCollection = ^OCollection;
   OCollection = Object (TObject)
   Private
      Size     : Integer;
      First    : PNodo;
      Last     : PNodo;
      Select   : PNodo;
      Freedown : Boolean;
   Public
      Constructor Init;
      Procedure   InsertItem(ImputItem : Pointer);
      Procedure   DeleteItem(Index : Integer);
      Procedure   FreeItem(DItem : Pointer);
      Function    GetItem(Index : Integer) : Pointer;
      Function    GetSelected : Pointer;
      Function    GetFirst : Pointer;
      Function    GetNext : Pointer;
      Function    GetNextSelected : Pointer;
      Function    GetSize : Integer;
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Procedure   Run; Virtual;
      Procedure   SetFree(f : boolean);
      Procedure   Free; Virtual;
      Destructor  Done; Virtual;
   End;

IMPLEMENTATION

{******* IMPLEMENTACAO DOS METODOS DO OBJETO OCollection **************}

CONSTRUCTOR OCollection.Init;
Begin
   TObject.Init(0,0,0,0,Nil);
   First    := Nil;
   Select   := Nil;
   Last     := Nil;
   Size     := 0;
   Freedown := True;
End;

{***** PROCEDIMENTO QUE INSERE UM ITEM INICIALIZADO NA LISTA ***********}

PROCEDURE OCollection.InsertItem(ImputItem : Pointer);

Var
  Vazio: Boolean;

Begin
   Vazio := Size = 0;
   Inc(Size);

   New(Select);
   Select^.Item := ImputItem;
   Select^.Next := Nil;

   If (Not Vazio) Then
      Last^.Next := Select
   Else
      First := Select;
   Last := Select;
End;

{******* EXCLUI UM ITEM DA LISTA E O LIBERA DA MEMORIA ******************}

PROCEDURE OCollection.DeleteItem(Index : Integer);

Var
   Ant  : PNodo;
   i    : Integer;
   Achou: Boolean;

Begin
   Achou  := False;
   Ant    := Nil;
   Select := First;
   i      := 1;
   While ((Select <> Nil) and (i <= Index) and (Not Achou)) Do
   Begin
      If (i = Index) Then
      Begin
         Achou := True;
         If (Select = First) Then
         Begin
            First := Select^.Next;
            Dispose(Select^.Item, Done);
            Dispose(Select);
         End
         Else If (Select = Last) Then
         Begin
            Dispose(Select^.Item, Done);
            Dispose(Select);
            Ant^.Next := Nil;
         End
         Else
         Begin
            Ant^.Next := Select^.Next;
            Dispose(Select^.Item, Done);
            Dispose(Select);
         End;
         Select := First;
         Dec(Size);
      End;
      Ant  := Select;
      Select := Select^.Next;
      Inc(i);
   End;
End;

PROCEDURE OCollection.FreeItem(DItem : Pointer);

Var
   Pont : PNodo;
   Ant  : PNodo;

Begin
   Ant  := First;
   Pont := First;
   While (Pont <> Nil) and (Pont^.Item <> DItem) Do
   Begin
      Pont := Pont^.Next;
      If Pont^.Item = DItem Then
      Begin
         Ant^.Next := Pont^.Next;
         Dispose(Pont^.Item, Done);
         Dispose(Pont);
         Dec(Size);
      End;
      Pont := Ant^.Next;
   End;
End;

FUNCTION OCollection.GetItem(Index : Integer) : Pointer;

Var
   Obj  : PObject;
   i    : Integer;

Begin
   Obj   := Nil;
   Select:= First;
   i     := 1;
   While ((i <= Index) and (Select <> Nil)) Do
   Begin
      If (i = Index) Then
         Obj := Select^.Item
      Else
         Select := Select^.Next;
      Inc(i);
   End;
   GetItem := Obj;
End;

FUNCTION OCollection.GetFirst : Pointer;
Begin
   Select := First;
   If (Select <> Nil) Then
      GetFirst := Select^.Item
   Else
      GetFirst := Nil;
End;

FUNCTION OCollection.GetSelected : Pointer;

Begin
   If (Select <> Nil) Then
      GetSelected := Select^.Item
   Else
      GetSelected := Nil;
End;

FUNCTION OCollection.GetNext : Pointer;
Begin
   If (Select <> Nil) Then
   Begin
      Select := Select^.Next;
      If Select = Nil Then GetNext := Nil
      Else GetNext := Select^.Item;
   End
   Else GetNext := Nil;
End;

FUNCTION OCollection.GetNextSelected : Pointer;

Begin
   If Select <> Nil Then
   Begin
      Select := Select^.Next;
      If Select = Nil Then Select := First;
      GetNextSelected := Select^.Item;
   End
   Else GetNextSelected := Nil;
End;

FUNCTION OCollection.GetSize : Integer;

Begin
   GetSize := Size;
End;

PROCEDURE OCollection.Run;
Var
   Pont : PNodo;

Begin
   Pont:= First;
   While Pont <> Nil  Do
   Begin
      Pont^.Item^.Run;
      Pont := Pont^.Next;
   End;
End;

PROCEDURE OCollection.Show;

Var Pont : PNodo;

Begin
   Pont:= First;
   While Pont <> Nil  Do
   Begin
      Pont^.Item^.Show;
      Pont := Pont^.Next;
   End;
End;

PROCEDURE OCollection.Draw;

Var Pont : PNodo;

Begin
   Pont:= First;
   While Pont <> Nil  Do
   Begin
      Pont^.Item^.Draw;
      Pont := Pont^.Next;
   End;
End;

PROCEDURE OCollection.SetFree(f : Boolean);
Begin
   Freedown := f;
End;

PROCEDURE OCollection.Free;

Var
   Pont : PNodo;

Begin
   While (First <> Nil) Do
   Begin
      Pont := First;
      First := First^.Next;
      If (Freedown) Then Dispose(Pont^.Item, Done);
      Dispose(Pont);
   End;

   First    := Nil;
   Select   := Nil;
   Last     := Nil;
   Size     := 0;
End;


DESTRUCTOR OCollection.Done;

Var
   Pont : PNodo;

Begin
   While (First <> Nil) Do
   Begin
      Pont := First;
      First := First^.Next;
      If (Freedown) Then Dispose(Pont^.Item, Done);
      Dispose(Pont);
   End;
   TObject.Done;
End;


End.
