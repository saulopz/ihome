{**********************************************

       File : msg.pas
 Developper : Saulo Popov Zambiasi
Last Update : Feb/14/2002



    AGENTS TREES COMMUNICATION PROTOCOL - ATCP
    ------------------------------------------


MESSAGE STRUCTURE:

   Sender    : 3 bytes
   Receiver  : 3 bytes

   X:X:X-- X : 0->255 (255 Broadcast)
   | | |
   | | +-- Agent Address
   | +---- Subgroup - Agent Type
   +------ Group - Micro Server Address

   0:0:0 -> Destination: MicroSystem

   Conttents : ?? bytes

   +--------+----------+-----------+
   | Sender | Receiver | Conttents |
   +--------+----------+-----------+

   AGENT TYPE

      1 - Sensor Presence         (all)
      2 - Sensor Sound/voice      (all)
      3 - Sensor Lightness        (Ligth)
      4 - Sensor Temperature      (Air-Condicionning, Ventilator)
      5 - Sensor Whater           (Door/Window)
      6 - Sensor Grease (gordura) (Extractor)


     51 - Window/Door
     52 - Light
     53 - Stove (fogao)
     54 - Freezer
     55 - Microwave
     56 - Coffe Maker
     57 - Extractor (exaustor)
     58 - TV
     59 - Cable
     60 - Video K7
     61 - DVD
     62 - Sound Stereo
     63 - Computer
     64 - Air-condicionning
     65 - Ventilator
     66 - Showwer
     67 - Clothes wash
     68 - Clothes dryer


MESSAGES:

  +---------------------+
  | Request  | Expected |
  +---------------------+
  | RR       | IA       |
  | RN       | IA       |
  | RS       | IS       |
  | RA       | IA       |
  | IP IL IT |          |
  | IW IG IC |          |
  |          |          |
  +---------------------+

  REQUEST

     RRx - Who [TYPE] whas on more recently in [SERVER] (to SuperSystem)
     RNx - Who [TYPE] is on now in [SERVER]             (to SuperSystem)
     RAx - Who [TYPE] is in [SERVER]                    (to SuperSystem) ??? MicroSystem
     RSx - Agent [ADDRESS], Send me your settings       (to Agent)

       x -> X:X:X -> [Server:Type:Address]


  INFORMATIONS

     IPx - Presence detected  [0|1]
     ILx - Lightness is X     [0|1]
     ITx - Temperature is X   [value]
     IWx - Watter detected    [0|1]
     IGx - Grease detected    [0|1]
     ISx - My Settings is X

     IS:X:X:X:X:X:X:XX:X:X:X:X
        | | | | | |  | | | | |
        | | | | | |  | | | | +- Sleep
        | | | | | |  | | | +--- Lock
        | | | | | |  | | +----- Level 2
        | | | | | |  | +------- Level 1
        | | | | | |  +--------- Year
        | | | | | +------------ Month
        | | | | +-------------- Day
        | | | +---------------- Sec
        | | +------------------ Min
        | +-------------------- Hour
        +---------------------- On

     IAx - The Agent is

     IA:X:X:X
        | | |
        | | +-- Agent Address
        | +---- Subgroup - Agent Type
        +------ Group - Micro Server Address


  COMMANDS

     Cx - Sound command X

     C:X:X:X:X:X
       | | | | |
       | | | | +- Sleep   (255 = Void)
       | | | +--- Lock    (255 = Void)
       | | +----- Level 2 (255 = Void)
       | +------- Level 1 (255 = Void | 254 = Video) ?????
       +--------- On      (255 = Void)


**********************************************}


UNIT Msg;

INTERFACE

CONST

   {*** Localization in message ***}

   SENDER_MS  =  1;
   SENDER_TP  =  2;
   SENDER_ID  =  3;
   RECEIV_MS  =  4;
   RECEIV_TP  =  5;
   RECEIV_ID  =  6;

   { Messages types }

   MESG_TP    =  7;
   MESG_SUBTP =  8;

   { Settings }

   INF_ON     =  9;
   INF_HOUR   = 10;
   INF_MIN    = 11;
   INF_SEC    = 12;
   INF_DAY    = 13;
   INF_MONTH  = 14;
   INF_YEARHI = 15;
   INF_YEARLO = 16;
   INF_LEVEL1 = 17;
   INF_LEVEL2 = 18;
   INF_LOCK   = 19;
   INF_SLEEP  = 20;

   { Agent Address }

   AGENT_MS   =  9;
   AGENT_TP   = 10;
   AGENT_ID   = 11;

   { Commands}

   CMD_ON     = 8;
   CMD_LEVEL1 = 9;
   CMD_LEVEL2 = 10;
   CMD_LOCK   = 11;
   CMD_SLEEP  = 12;

   { Request type }

   REQUEST_TYPE       = 8;
   REQUEST_AGENT_TYPE = 9;
   REQUEST_CODE       = 9;
   INFO_REQUEST_CODE  = 21;

   { From To }

   ALL   = #255;
   SUPER = #0;

   MAXBUFFER   = 50;
   SIZEMESSAGE = 21;


TYPE
   Message = String[SIZEMESSAGE];

   PBufferMessage = ^OBufferMessage;
   OBufferMessage = Object
      First  : 1..MAXBUFFER+1;
      Last   : 1..MAXBUFFER+1;
      Buffer : Array[1..MAXBUFFER] of Message;
      Constructor Init;
      Procedure   Add(Mesg : Message);
      Function    Get : Message;
      Procedure   Reset;
      Destructor  Done;
   End;


IMPLEMENTATION

{**************************************************

   Initialize Message Buffer

***************************************************}


Constructor OBufferMessage.Init;
Begin
   First := 1;
   Last  := 1;
End;

{**************************************************

   Include a new message on Message Buffer

***************************************************}


Procedure OBufferMessage.Add(Mesg: Message);

Var aux : Integer;

begin
   aux := Last+1;
   If (aux = MAXBUFFER+1) Then aux := 1;
   if (aux <> First) Then
   Begin
      Buffer[Last] := Mesg;
      Last := aux;
   End;
End;

{**************************************************

   Get a message from Message Buffer, and erase then

***************************************************}

Function OBufferMessage.Get: Message;
Begin
   If (Last <> First) Then
   Begin
      Get   := Buffer[First];
      Buffer[First] := '';
      First := First+1;
      If (First = MAXBUFFER+1) Then First := 1;
   End
   Else Begin
      Get := 'NULL';
   End;
End;

{**************************************************

   Erase all message from Message Buffer

***************************************************}

Procedure OBufferMessage.Reset;
Begin
   First := 1;
   Last  := 1;
End;


{**************************************************

  Destructor of Message Buffer

***************************************************}

Destructor OBufferMessage.Done;
Begin
End;

End.
