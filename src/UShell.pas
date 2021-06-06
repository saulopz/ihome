unit UShell;

interface

Uses
   MapDB;

Function Shell(s : String; var ret : String; sec : Byte) : String;

implementation

Function Shell(s : String; var ret : String; sec : Byte) : String;

Var
   cmd     : String;
   auxStr  : String;
   auxByte : Byte;
   i       : Integer;
   err     : String;
   Invalid : Boolean;

Begin
   Invalid := True;
   err     := 'NULL';
   cmd     := #255#255#255;

   { 1 - Verify system }
   if (Pos('CASA', s) <> 0) Then cmd := cmd + #255
   Else If (Pos('SETOR', s) <> 0) Then
   Begin
      auxByte := Pos('SETOR', s);
      auxStr  := Copy(s, auxByte+6, 2);
      Val(auxStr, auxByte, i);
      If (i = 0) Then cmd := cmd + chr(auxByte)
      Else err := 'ERRO: Setor invalido.';
   End
   Else cmd := cmd + Chr(sec);

   { 2 - Verify agent type }
   auxByte := 0;
   While ((i < 100) and (auxByte = 0)) Do
   Begin
      If (Pos(GetUnitString(i), s) <> 0) Then auxByte := 1
      Else i := i+1;
   End;
   If (auxByte <> 0) Then cmd := cmd + Chr(i)
   Else cmd := cmd + #255;

   { 3 - Just put ALL to agent address }
   cmd := cmd + #255;
   { 4 - Inform that it is a command }
   cmd := cmd + 'C';

   { 5 - Verify if is to turn on or off }
   If ((Pos('DESLIGAR', s) <> 0) or (Pos('FECHAR', s) <> 0)) Then cmd := cmd + #0
   Else If ((Pos('LIGAR', s) <> 0) or (Pos('ABRIR', s) <> 0)) Then cmd := cmd + #1
   Else cmd := cmd + #255;
   if (cmd[Length(cmd)] <> #255) Then Invalid := False;

   { 6 - Verify Level 1 }
   If (Pos('NIVEL1', s) <> 0) Then
   Begin
      auxByte := Pos('NIVEL1', s);
      auxStr  := Copy(s, auxByte+7, 2);
      Val(auxStr, auxByte, i);
      If (i = 0) Then cmd := cmd + chr(auxByte)
      Else err := 'ERRO: Nivel 1 Invalido.';
   End Else cmd := cmd + #255;
   if (cmd[Length(cmd)] <> #255) Then Invalid := False;

   { 7 - Verify Level 2 }
   If (Pos('NIVEL2', s) <> 0) Then
   Begin
      auxByte := Pos('NIVEL2', s);
      auxStr  := Copy(s, auxByte+7, 2);
      Val(auxStr, auxByte, i);
      If (i = 0) Then cmd := cmd + chr(auxByte)
      Else err := 'ERRO: Nivel 2 invalido.';
   End Else cmd := cmd + #255;
   if (cmd[Length(cmd)] <> #255) Then Invalid := False;

   { 8 - Verify Lock }
   If (Pos('DESTRAVAR', s) <> 0) Then cmd := cmd + #0
   Else If (Pos('TRAVAR', s) <> 0) Then  cmd := cmd + #1
   Else cmd := cmd + #255;
   if (cmd[Length(cmd)] <> #255) Then Invalid := False;

   { 8 - Verify Sleep }
   If (Pos('DORMIR', s) <> 0) Then cmd := cmd + #1
   Else If (Pos('ACORDAR', s) <> 0) Then cmd := cmd + #0
   Else cmd := cmd + #255;
   if (cmd[Length(cmd)] <> #255) Then Invalid := False;

   If (Invalid) Then err := 'ERRO: Comando invalido.';

   if (err <> 'NULL') Then ret := 'NULL'
   Else ret := cmd;
   Shell := err;
End;


end.
