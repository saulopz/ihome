UNIT Config;

INTERFACE

TYPE
   Str12 = String[12];

   SetofCourse = (CDOWN, CUP, CLEFT, CRIGHT, CLEFTDOWN,
                  CRIGHTDOWN, CLEFTUP, CRIGHTUP);
   Direction   = (HORIZONTAL, VERTICAL);
   Alignation  = (LEFT, CENTER, RIGHT);

CONST
//   COLOR_BORDER  = 14;
//   COLOR_TEXT    = 14;
//   COLOR_BACKOFF =  6;
//   COLOR_BACKON  =  2;
//   COLOR_BACKGR  =  0;
   COLOR_BORDER  =  9;
   COLOR_TEXT    = 11;
   COLOR_BACKOFF =  1;
   COLOR_BACKON  =  9;
   COLOR_BACKGR  =  0;

   GENERAL_ALIGN = CENTER;

Function StringUpper(S : String) : String;

IMPLEMENTATION

Function StringUpper(S : String) : String;

Var i : Byte;

Begin
    For i := 1 To Length(S) Do
       S[i] := UpCase(S[i]);
    StringUpper := S;
End;


End.