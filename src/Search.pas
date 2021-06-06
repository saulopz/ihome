{****************************************************************

   Lista de requisicoes ao servidor. Cada uma é avaliada e
   tratada separadamente para nao haver confusao.

****************************************************************}

unit Search;

interface

Uses
   Msg, LowLevel;

CONST
   MAXTIME = 20;

TYPE
   PSuperRequest = ^OSuperRequest;
   OSuperRequest = Record
      Code     : Byte;
      RType    : Char;
      Client   : Array[1..3] of Byte;
      Response : Array[1..3] of Byte;
      Counter  : Byte;
      Time     : Double;
      Prev     : PSuperRequest;
      Next     : PSuperRequest;
   End;

   PSearch = ^OSearch;
   OSearch = Object
      List    : PSuperRequest;
      Size    : Byte;
      First   : PSuperRequest;
      Last    : PSuperRequest;
      MesgOut : Message;
      Request : Message;
      Constructor Init;
      Procedure   Run;
      Procedure   Add(m : Message);
      Procedure   Info(m : Message);
      Procedure   Del(Var Pont : PSuperRequest);
      Function    HasMessage : Boolean;
      Function    HasRequest : Boolean;
      Function    GetMessage : Message;
      Function    GetRequest : Message;
      Destructor  Done;
   End;

implementation

Constructor OSearch.Init;
Begin
   List    := Nil;
   First   := Nil;
   Last    := Nil;
   Size    := 0;
   MesgOut := 'NULL';
   Request := 'NULL';
End;

Function OSearch.HasMessage : Boolean;
Begin
   HasMessage := MesgOut <> 'NULL';
End;

Function OSearch.HasRequest : Boolean;
Begin
   HasRequest := Request <> 'NULL';
End;

Function OSearch.GetMessage : Message;
Begin
   GetMessage := MesgOut;
   MesgOut    := 'NULL';
End;

Function OSearch.GetRequest : Message;
Begin
   GetRequest := Request;
   Request    := 'NULL';
End;

Procedure OSearch.Add(m : Message);

Var
   Pont : PSuperRequest;

Begin
   New(Pont);
   If (Last <> Nil) Then
   Begin
      If (Last^.Code < 255) Then Pont^.Code := Last^.Code + 1
      Else Pont^.Code := 1;
   End Else Pont^.Code := 1;
   Pont^.RType := m[REQUEST_TYPE];
   Pont^.Client[1] := Ord(m[SENDER_MS]);
   Pont^.Client[2] := Ord(m[SENDER_TP]);
   Pont^.Client[3] := Ord(m[SENDER_ID]);
   Pont^.Response[1] := 0;
   Pont^.Response[1] := 0;
   Pont^.Response[1] := 0;
   Pont^.Time := 0;
   Pont^.Counter := MAXTIME;
   Pont^.Next := Nil;
   Pont^.Prev := Nil;

   Request := #0#0#0#255 + m[SENDER_TP] + #255 + 'RS' + Chr(Pont^.Code);

   If (Last <> Nil) Then
   Begin
      Last^.Next := Pont;
      Pont^.Prev := Last;
      Last := Pont;
      Size := Size + 1;
   End Else
   Begin
      First := Pont;
      Last  := First;
      Size  := 1;
   End;
End;

Procedure OSearch.Info(m : Message);

Var
   TimeB : Double;
   Found : Boolean;
   Pont  : PSuperRequest;

Begin
   Found := False;
   Pont  := First;
   While ((Pont <> Nil) and (Not Found)) Do
   Begin
      If (Pont^.Code = Ord(m[INFO_REQUEST_CODE])) Then
      Begin
         If (Pont^.Counter > 0) Then
         Begin
            If (Pont^.RType = 'R') Then
            Begin
               TimeB := GetStructTime(m);
               If (TimeB > Pont^.Time) Then
               Begin
                  Pont^.Time := TimeB;
                  Pont^.Response[1] := Ord(m[SENDER_MS]);
                  Pont^.Response[2] := Ord(m[SENDER_TP]);
                  Pont^.Response[3] := Ord(m[SENDER_ID]);
               End
            End
            Else If (Pont^.RType = 'N') Then
            Begin
               If (m[INF_ON] = #1) Then
               Begin
                  Pont^.Response[1] := Ord(m[SENDER_MS]);
                  Pont^.Response[2] := Ord(m[SENDER_TP]);
                  Pont^.Response[3] := Ord(m[SENDER_ID]);
                  Pont^.Counter := 0;
               End;
            End
            Else If (Pont^.RType = 'A') Then
            Begin
               Pont^.Response[1] := Ord(m[SENDER_MS]);
               Pont^.Response[2] := Ord(m[SENDER_TP]);
               Pont^.Response[3] := Ord(m[SENDER_ID]);
               Pont^.Counter := 0;
            End;
         End;
         Found := True;
      End;
      Pont := Pont^.Next;
   End;
End;

Procedure OSearch.Del(Var Pont : PSuperRequest);
Begin
   If (Pont <> Nil) Then
   Begin
      If (Pont^.Prev <> Nil) Then Pont^.Prev^.Next := Pont^.Next;
      If (Pont^.Next <> Nil) Then Pont^.Next^.Prev := Pont^.Prev;
      If (Pont = First) Then First := Pont^.Next;
      If (Pont = Last)  Then Last  := Pont^.Prev;
      Size := Size - 1;
      Dispose(Pont);
      Pont := Nil;
   End;
End;

Procedure OSearch.Run;

Var
   Pont, aux : PSuperRequest;

Begin
   Pont := First;
   While (Pont <> Nil) Do
   Begin
      aux := Nil;
      If ((Pont^.Counter = 0) and (Not HasMessage)) Then
      Begin
         { If a response was founded, then send a message }
         If (Pont^.Response[1] > 0) Then
         Begin
            MesgOut := #0#0#0 + Char(Pont^.Client[1]) + Char(Pont^.Client[2]) +
               Char(Pont^.Client[3]) + 'IA' + Char(Pont^.Response[1]) +
               Char(Pont^.Response[2]) + Char(Pont^.Response[3]);
         End
         Else  { Else send a Null Response }
         Begin
            MesgOut := #0#0#0 + Char(Pont^.Client[1]) + Char(Pont^.Client[2]) +
               Char(Pont^.Client[3]) + 'IN';
         End;
         aux := Pont^.Next;
         Del(Pont);
      End;
      If (Pont = Nil) Then Pont := aux
      Else Begin
         If (Pont^.Counter > 0) Then Dec(Pont^.Counter);
         Pont := Pont^.Next;
      End;
   End;
End;

Destructor OSearch.Done;

Var Pont : PSuperRequest;

Begin
   Pont := First;
   While (Pont <> Nil) Do
   Begin
      Pont := Pont^.Next;
      Dispose(First);
      First := Pont;
   End;
End;

end.
