Program teste;


Uses LowLevel;

Type
   Message = String[30];


Function MakeInfoMesg(cl : Time) : Message;

Var
   Mesg   : Message;
   IH, IL : Byte;

Begin
   IL := Byte(cl.Year and $00FF);
   IH := Byte((cl.Year and $FF00) shr 8);

   Mesg := Chr(cl.Hour) + Chr(cl.Min) + Chr(cl.Sec) +
           Chr(cl.Day) + Chr(cl.Month) + Chr(IH) + Chr(IL);

   MakeInfoMesg := Mesg;
End;


Procedure DestructInfoMesg(Var cl : Time; msg : Message);

Var
   Mesg   : Message;
   IH, IL : Byte;

Begin
   With cl do
   Begin
      Hour := Ord(msg[1]);
      Min  := Ord(msg[2]);
      Sec  := Ord(msg[3]);
      Day  := Ord(msg[4]);
      Month:= Ord(msg[5]);
      Year := integer(integer(Ord(msg[6])) shl 8) or integer(ord(msg[7]));
   End;
End;



Var
   clock : Time;
   msg   : Message;

Begin
   GetServerTime(Clock);

   Writeln;
   Writeln('Hour  : ', Clock.Hour);
   Writeln('Min   : ', Clock.Min);
   Writeln('Sec   : ', Clock.Sec);
   Writeln('Day   : ', Clock.Day);
   Writeln('Month : ', Clock.Month);
   Writeln('Year  : ', Clock.Year);
   Writeln;
   msg := MakeInfoMesg(Clock);
   Writeln(msg);
   DestructInfoMesg(Clock, msg);
   Writeln;
   Writeln('Hour  : ', Clock.Hour);
   Writeln('Min   : ', Clock.Min);
   Writeln('Sec   : ', Clock.Sec);
   Writeln('Day   : ', Clock.Day);
   Writeln('Month : ', Clock.Month);
   Writeln('Year  : ', Clock.Year);
   Writeln;

End.