UNIT LowLevel;

INTERFACE

USES
   SysUtils,
   {$IFDEF MSWINDOWS}
   Windows,
   {$ENDIF}
   {$IFDEF LINUX}
   Types,
   Libc,
   {$ENDIF}
   SysConst,
   Msg;

TYPE
   { Hour and Date structure }

   Time = Record
      Hour  : Byte;
      Min   : Byte;
      Sec   : Byte;
      Day   : Byte;
      Month : Byte;
      Year  : Integer;
   End;

Procedure GetServerTime(Var Clock : Time);
Function GetStructTime(Mesg : Message) : Double;

IMPLEMENTATION


Procedure GetServerTime(Var Clock : Time);

Var
  DTime : TDateTime;
  STime : TSystemTime;

Begin
   DTime := Now;
   DateTimeToSystemTime(DTime, STime);
   Clock.Hour  := STime.wHour;
   Clock.Min   := STime.wMinute;
   Clock.Sec   := STime.wSecond;
   Clock.Day   := STime.wDay;
   Clock.Month := STime.wMonth;
   Clock.Year  := STime.wYear;
End;

Function GetStructTime(Mesg : Message) : Double;

Var
   Year  : Integer;
   Hour  : Integer;

Begin
   Year := Integer(Integer(Ord(Mesg[INF_YEARHI])) shl 8) or
                   Integer(Ord(Mesg[INF_YEARLO]));
   Hour := (Ord(Mesg[INF_HOUR])*60*60) +
           (Ord(Mesg[INF_MIN])*60) +
           (Ord(Mesg[INF_SEC]));
   GetStructTime := (Year*10000) +
                    (Ord(Mesg[INF_MONTH])*100) +
                    (Ord(Mesg[INF_DAY])) +
                    (Hour/10000);
End;


End.