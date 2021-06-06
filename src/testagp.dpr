program testagp;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  alpgraph,
  ag_sdl;

begin
    AGInit(640,480,8,'demo1',false,false);
    DrawFilledRectangle(screen,5,5,100,100,14);
    Update(0,0,0,0); //refresh the entire screen
    RKey;
    AGDone;
end.
