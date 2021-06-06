{ ALPGRAPH }
{ main unit (platform independent things) }
{ (C) 2001 Laszlo Agocs (alp@dwp42.org) }

unit alpgraph;

interface

const
  alpgraph_ver='1.5.0';

  SHIFT_SHIFT=1; //shift state flags: left or right shift
  SHIFT_CTRL=2; //shift state flags: left or right control
  SHIFT_ALT=4; //shift state flags: left or right alt
  SHIFT_CAPS=8; //shift state flags: caps lock is on/off
  SHIFT_NUM=16; //shift state flags: num lock is on/off

  MBUT_LEFT=1; //mouse button state flags: left
  MBUT_MID=2; //mouse button state flags: middle
  MBUT_RIGHT=4; //mouse button state flags: right

  colortab16:array [0..15] of word=(
    $0000,
    $0015,
    $0540,
    $0555,
    $A800,
    $A815,
    $AAA0,
    $AD55,
    $52AA,
    $52BF,
    $57EA,
    $57FF,
    $FAAA,
    $FABF,
    $FFEA,
    $FFFF
  );

  colortab32:array [0..15] of longint=(
    $000000,
    $0000A8,
    $00A800,
    $00A8A8,
    $A80000,
    $A800A8,
    $A85400,
    $A8A8A8,
    $545454,
    $5454FC,
    $54FC54,
    $54FCFC,
    $FC5454,
    $FC54FC,
    $FCFC54,
    $FCFCFC
  );

  AG_GL_RED_SIZE=0;
  AG_GL_GREEN_SIZE=1;
  AG_GL_BLUE_SIZE=2;
  AG_GL_ALPHA_SIZE=3;
  AG_GL_BUFFER_SIZE=4;
  AG_GL_DOUBLEBUFFER=5;
  AG_GL_DEPTH_SIZE=6;
  AG_GL_STENCIL_SIZE=7;
  AG_GL_ACCUM_RED_SIZE=8;
  AG_GL_ACCUM_GREEN_SIZE=9;
  AG_GL_ACCUM_BLUE_SIZE=10;
  AG_GL_ACCUM_ALPHA_SIZE=11;

type
  vgapalette=array [0..255] of packed record
    r,g,b:byte;
  end; //size of this record is 768 bytes

  PByte=^byte;
  PWord=^word;
  PLongint=^longint;

  TProc=procedure;

  PVidMem=^TVidMem;
  TVidMem=array [0..4096*1024-1] of byte; //4M
  PVidMemL=^TVidMemL;
  TVidMemL=array [0..1024*1024-1] of longint; //4M
  PVidMemW=^TVidMemW;
  TVidMemW=array [0..2048*1024-1] of word; //4M

  P24=^T24;
  T24=packed record
    r,g,b:byte;
  end;

  PSurface=^TSurface;
  TSurface=record
    w,h:integer; //width and height
    p:pointer; //wdosx: pointer to surface data / win32: pSDL_Surface
    transp:boolean; //true if a transparent color is set
    trans:longint; //transparent color
    pitch:integer; //filled by Lock (length of scanline / DOS: same as w)
    hw:boolean; //is it in video mem? (False in DOS)
    mustlock:boolean; //is Lock/Unlock needed for direct access
  end;

  TGrs=record
    is8bpp:boolean;
    n:integer;
    w,h:array of integer;
    pal:vgapalette;
    img:array of TSurface;
  end;

  TTimerProc=function(interval:longint;param:pointer):longint;cdecl;

  TFileFuncs=record
    open:function(fn:string):longint; //-1=error,other=file handle
    close:procedure(f:longint);
    read:function(f:longint;var dest;count:longint):longint;
    seek:function(f,newpos,o:longint):longint; //o: 0=set,1=cur,2=end
  end;

  TAGInitCallback=procedure;

  { *** platform dependent functions *** }
  TAGInit=function(xs,ys,bpp:integer;caption:ansistring;full,dblbuf:boolean):boolean;
  TAGDone=procedure;
  TUpdate=procedure(x1,y1,x2,y2:integer);
  T_SetPal=procedure(var srf:tsurface;var pal:vgapalette);
  TSetPal=procedure(var pal:vgapalette);
  TSetColor=procedure(color:byte;r,g,b:byte);
  TMkSurface=function(var srf:tsurface;w,h:integer;hw,t:boolean;trans:longint):boolean;
  TRmSurface=procedure(var srf:tsurface);
  TLock=function(var srf:tsurface):pvidmem;
  TUnlock=procedure(var srf:tsurface);
  Tblit=procedure(var src,dest:tsurface;x1,y1,x2,y2,dx,dy:integer);
  Tblit_force_notrans=procedure(var src,dest:tsurface;x1,y1,x2,y2,dx,dy:integer);
  TIdle=procedure;
  TIdleN=procedure(n:integer);
  TRKey=function:char;
  TKeyPress=function:boolean;
  TGetShiftStates=function:byte;
  TInstallInt=function(proc:TTimerProc;speed:integer):boolean;
  TRemoveInt=procedure(proc:TTimerProc);
  TGetTicks=function:longint;
  TShowMouse=procedure;
  THideMouse=procedure;
  TSetMouseCursor=procedure(newdata,newmask:pointer);
  TAGDelay=procedure(ms:integer);
  TWaitRetrace=procedure;

  { *** platform independent functions *** }
  TDrawStr8x16Ovr=procedure(dest:pointer;var fnt;x,y,w:integer;const s:shortstring;fc,bc:longint);pascal;

var
  ag_inited:boolean=false; //was AGInit called? (changed by AGInit and AGDone)
  mustquit:boolean=false; //updated by Idle / DOS: not used
  isactive:boolean=true; //updated by Idle / DOS: not used
  screen:tsurface;
  screenpal:vgapalette; //current palette
  rk_schar:boolean=false; //set by RKey, true if a scancode was returned
  keydown:array [0..255] of boolean; //keyboard state (W: updated by Idle)

  ag_mouseok:boolean=true; //is mouse available?
  ag_mousex,ag_mousey:integer; //updated by W:Idle|DOS:int if mouse is enabled
  ag_mouseb:integer; //mouse button state, set by W:Idle|DOS:int
  ag_mousevisible:boolean=false; //is the mouse cursor visible?

  vid_banked:boolean=false; //banked mode? (can be changed before AGInit!)
  vid_dblbuf:boolean; //is double buffering enabled?
  vid_bpp:integer; //bits per pixel (8 or 16 or 32)
  vid_bypp:integer; //bytes per pixel (1 or 2 or 4)
  vid_realbpp:integer; //bits per pixel (8 or 15 or 16 or 24 or 32)
  vid_rshift,vid_gshift,vid_bshift,vid_ashift:integer;
  vid_rmask,vid_gmask,vid_bmask,vid_amask:longint;
  vid_flags:integer=0;
  vid_ogl:array [0..11] of longint;

  pal_vga:vgapalette; //default palette
  pal_dn:vgapalette; //another built-in palette

  ff:TFileFuncs;
  default_ff:TFileFuncs;

  { *** platform dependent functions *** }
  _real_AGInit:TAGInit;
  _real_AGDone:TAGDone;
  Update:TUpdate;
  _SetPal:T_SetPal;
  SetPal:TSetPal;
  SetColor:TSetColor;
  MkSurface:TMkSurface;
  RmSurface:TRmSurface;
  Lock:TLock;
  Unlock:TUnlock;
  blit:Tblit;
  blit_force_notrans:Tblit_force_notrans;
  Idle:TIdle;
  IdleN:TIdleN;
  RKey:TRKey;
  KeyPress:TKeyPress;
  GetShiftStates:TGetShiftStates;
  InstallInt:TInstallInt;
  RemoveInt:TRemoveInt;
  GetTicks:TGetTicks;
  ShowMouse:TShowMouse;
  HideMouse:THideMouse;
  SetMouseCursor:TSetMouseCursor;
  AGDelay:TAGDelay;
  WaitRetrace:TWaitRetrace;
  ag_platform_id:string;

  { *** platform independent functions *** }
  DrawStr8x16Ovr:TDrawStr8x16Ovr;

  { for internal usage: }
  aginitcallback:procedure=nil;

{ *** platform independent functions *** }

procedure ag_halt(msg:ansistring);
function AGInit(xs,ys,bpp:integer;caption:ansistring='ag_app';full:boolean=true;dblbuf:boolean=false):boolean;
function AddAGInitCallback(proc:TAGInitCallback):boolean;
procedure ClearAGInitCallbacks;
procedure AGDone;
procedure PUpdate(x1,y1,x2,y2:integer);

procedure SetFileFuncs(var newff:TFileFuncs);
function GetFileFuncs:TFileFuncs;
procedure ff_readN(f:longint;var dest;count:longint;var numread:longint);

procedure GetPal(var pal:vgapalette);
procedure GetColor(color:byte;var r,g,b:byte);

//GetClosestColor is taken from SWAG (author: Scott Tunstall)
function GetClosestColor(var pal:vgapalette;red,green,blue:byte):byte;
function GetFurthestColor(var pal:vgapalette;red,green,blue:byte):byte;

function AllocSurface(w,h,t:integer):TSurface;
function AllocHWSurface(w,h,t:integer):TSurface;
procedure FreeSurface(var surface:TSurface);

procedure _24_to_16(src:p24;dest:pword;w,h,spitch,dpitch:integer);
procedure _24_to_32(src:p24;dest:pbyte;w,h,spitch,dpitch:integer);
procedure _16_to_24(src:pword;dest:p24;w,h,spitch,dpitch:integer);
procedure _32_to_24(src:pbyte;dest:p24;w,h,spitch,dpitch:integer);
procedure _8_to_16(src:pbyte;dest:pword;w,h,spitch,dpitch:integer;var pal:vgapalette);
procedure _8_to_24(src:pbyte;dest:p24;w,h,spitch,dpitch:integer;var pal:vgapalette);
procedure _8_to_32(src:pbyte;dest:pbyte;w,h,spitch,dpitch:integer;var pal:vgapalette);
procedure _32_to_16(src:pbyte;dest:pword;w,h,spitch,dpitch:integer);
procedure _16_to_32(src:pword;dest:pbyte;w,h,spitch,dpitch:integer);
procedure PutSurfaceData(var srf:tsurface;src:pvidmem;sbpp,spitch:integer);overload;
procedure PutSurfaceData(var srf:tsurface;src:pvidmem;sbpp,spitch:integer;var pal:vgapalette);overload;
procedure GetSurfaceData(var srf:tsurface;dest:pvidmem;dbpp,dpitch:integer);overload;
procedure GetSurfaceData(var srf:tsurface;dest:pvidmem;dbpp,dpitch:integer;var pal:vgapalette);overload;

function CalcRGB(r,g,b:byte):longint;
function GetR(col:longint):byte;
function GetG(col:longint):byte;
function GetB(col:longint):byte;
procedure GetRGB(col:longint;var r,g,b:byte);

procedure gclrscr(var srf:tsurface;color:longint);

procedure PutPixel(var dest:TSurface;x,y:integer;color:longint);
function GetPixel(var src:TSurface;x,y:integer):longint;

procedure hline(var dest:TSurface;x1,y,x2:integer;color:longint);
procedure vline(var dest:TSurface;x,y1,y2:integer;color:longint);

procedure DrawLine(var dest:TSurface;x1,y1,x2,y2:integer;color:longint);
procedure DrawCircle(var dest:TSurface;xc,yc,r:integer;color:longint);

procedure DrawRectangle(var dest:TSurface;x1,y1,x2,y2:integer;color:longint);
procedure DrawFilledRectangle(var dest:TSurface;x1,y1,x2,y2:integer;color:longint);

procedure DrawBox(var dest:TSurface;x1,y1,x2,y2:integer;f1c,f2c,bc,t:longint);

function LoadPCX8(filename:string;var destpal:vgapalette):TSurface;overload;
function LoadPCX8(filename:string):TSurface;overload;
function SavePCX8(filename:string;var src:TSurface;var srcpal:vgapalette;x1,y1,x2,y2:integer):boolean;
function LoadBMP8(filename:string;var destpal:vgapalette):TSurface;overload;
function LoadBMP8(filename:string):TSurface;overload;
function SaveBMP8(filename:string;var src:TSurface;var srcpal:vgapalette;x1,y1,x2,y2:integer):boolean;

function LoadBMP24(filename:string):TSurface;
function SaveBMP24(filename:string;var src:TSurface;x1,y1,x2,y2:integer):boolean;overload;
function SaveBMP24(filename:string;var src:TSurface;x1,y1,x2,y2:integer;var srcpal:vgapalette):boolean;overload;

procedure DrawChar(var dest:TSurface;var fnt;x,y:integer;ch:char;fc,bc:longint;ovr:boolean;cxsiz,cysiz:byte);
procedure DrawStr(var dest:TSurface;var fnt;x,y:integer;s:string;fc,bc:longint;ovr:boolean;cxsiz,cysiz:byte);
procedure DrawStr8x16Ovr8(dest:pointer;var fnt;x,y,w:integer;const s:shortstring;fc,bc:longint);pascal;
procedure DrawStr8x16Ovr16(dest:pointer;var fnt;x,y,w:integer;const s:shortstring;fc,bc:longint);pascal;
procedure DrawStr8x16Ovr32(dest:pointer;var fnt;x,y,w:integer;const s:shortstring;fc,bc:longint);pascal;

function LoadGrs(filename:string;var grs:TGrs):boolean;
procedure UnloadGrs(var grs:TGrs);
function SaveGrs(filename:string;var grs:TGrs):boolean;

function PlayFLI(filename:string;x1,y1,x2,y2,sx,sy:integer;loop:boolean;maxloop:integer):boolean;

implementation

uses rle,chars;

{$I+}

{$ifndef linux}
function MessageBoxA(w:integer;t,c:pchar;typ:integer):integer;stdcall;external 'user32.dll';
{$endif}

procedure msgbox(s:ansistring);
begin
  {$ifdef linux}writeln(s);{$else}
  MessageBoxA(0,pchar(s),'ALPGRAPH',0);
  {$endif}
end;

procedure ag_halt(msg:ansistring);
begin
  if IsConsole then writeln(msg) else msgbox(msg);
  halt;
end;

var
  saved_screen:pvidmem=nil;
  initcallbacks:array of TAGInitCallback=nil;

function AGInit(xs,ys,bpp:integer;caption:ansistring='ag_app';full:boolean=true;dblbuf:boolean=false):boolean;
var
  i:integer;
begin
  result:=false;
  if ag_inited then exit;
  move(_pal_vga,pal_vga,768);
  move(_pal_dn,pal_dn,768);
  if assigned(_real_AGInit) then result:=_real_AGInit(xs,ys,bpp,caption,full,dblbuf) else begin
    ag_halt('FATAL ERROR: no alpgraph driver was linked');
  end;
  if result then begin
    ag_inited:=true;
    case vid_bpp of
      8:begin
        DrawStr8x16Ovr:=DrawStr8x16Ovr8;
      end;
      16:begin
        DrawStr8x16Ovr:=DrawStr8x16Ovr16;
      end;
      32:begin
        DrawStr8x16Ovr:=DrawStr8x16Ovr32;
      end;
    end;
    getmem(saved_screen,screen.w*screen.h*vid_bypp);
    for i:=0 to high(initcallbacks) do initcallbacks[i];
  end;
end;

function AddAGInitCallback(proc:TAGInitCallback):boolean;
begin
  setlength(initcallbacks,length(initcallbacks)+1);
  initcallbacks[high(initcallbacks)]:=proc;
  result:=true;
end;

procedure ClearAGInitCallbacks;
begin
  initcallbacks:=nil;
end;

procedure AGDone;
begin
  if not ag_inited then exit;
  if assigned(_real_AGDone) then _real_AGDone;
  ag_inited:=false;
end;

procedure PUpdate(x1,y1,x2,y2:integer);
begin
  if vid_dblbuf then getsurfacedata(screen,saved_screen,vid_bpp,screen.w*vid_bypp);
  update(x1,y1,x2,y2);
  if vid_dblbuf then putsurfacedata(screen,saved_screen,vid_bpp,screen.w*vid_bypp);
end;

procedure SetFileFuncs(var newff:TFileFuncs);
begin
  ff:=newff;
end;

function GetFileFuncs:TFileFuncs;
begin
  result:=ff;
end;

function _ff_open(fn:string):longint;
var
  p:pointer;
begin
  getmem(p,sizeof(file));
  result:=longint(p);
  assign(file(p^),fn);
  {$I-}
  reset(file(p^),1);
  {$I+}
  if ioresult<>0 then result:=0;
end;

procedure _ff_close(f:longint);
var
  p:pointer;
begin
  p:=pointer(f);
  close(file(p^));
  freemem(p);
end;

function _ff_read(f:longint;var dest;count:longint):longint;
begin
  blockread(file(pointer(f)^),dest,count,result);
end;

function _ff_seek(f,newpos,o:longint):longint;
begin
  case o of
    0:seek(file(pointer(f)^),newpos);
    1:seek(file(pointer(f)^),newpos+filepos(file(pointer(f)^)));
    2:seek(file(pointer(f)^),filesize(file(pointer(f)^))+newpos);
  end;
  result:=filepos(file(pointer(f)^));
end;

procedure ff_readN(f:longint;var dest;count:longint;var numread:longint);
begin
  numread:=ff.read(f,dest,count);
end;

procedure GetPal(var pal:vgapalette);
begin
  move(screenpal,pal,768);
end;

procedure GetColor(color:byte;var r,g,b:byte);
begin
  r:=screenpal[color].r;
  g:=screenpal[color].g;
  b:=screenpal[color].b;
end;

function GetClosestColor(var pal:vgapalette;red,green,blue:byte):byte;
var
  i,j:byte;
  rgbtotal1,rgbtotal2:word;
begin
  j:=0;
  rgbtotal1:=255+255+255;
  for i:=0 to 255 do begin
    rgbtotal2:=abs(pal[i].r-red)+abs(pal[i].g-green)+abs(pal[i].b-blue);
    if rgbtotal2<=rgbtotal1 then begin
      j:=i;
      if rgbtotal2=0 then break else rgbtotal1:=rgbtotal2;
    end;
  end;
  result:=j;
end;

function GetFurthestColor(var pal:vgapalette;red,green,blue:byte):byte;
var
  i,j:byte;
  rgbtotal1,rgbtotal2:word;
begin
  j:=0;
  rgbtotal1:=0;
  for i:=0 to 255 do begin
    rgbtotal2:=abs(pal[i].r-red)+abs(pal[i].g-green)+abs(pal[i].b-blue);
    if rgbtotal2>=rgbtotal1 then begin
      j:=i;
      if rgbtotal2=255+255+255 then break else rgbtotal1:=rgbtotal2;
    end;
  end;
  result:=j;
end;

function AllocSurface(w,h,t:integer):TSurface;
begin
  if not MkSurface(result,w,h,false,(t<>-1),t) then begin
    result.w:=0;result.h:=0;
  end;
end;

function AllocHWSurface(w,h,t:integer):TSurface;
begin
  if not MkSurface(result,w,h,true,(t<>-1),t) then begin
    result.w:=0;result.h:=0;
  end;
end;

procedure FreeSurface(var surface:TSurface);
begin
  RmSurface(surface);
end;

//conv.start

procedure _24_to_16(src:p24;dest:pword;w,h,spitch,dpitch:integer);
var
  x,y:integer;
  os:p24;
  od:pword;
begin
  os:=src;od:=dest;
  for y:=0 to h-1 do begin
    src:=pointer(longint(os)+y*spitch);
    dest:=pointer(longint(od)+y*dpitch);
    for x:=0 to w-1 do begin
      dest^:=((src^.b div 8) shl 11) or ((src^.g div 4) shl 5) or (src^.r div 8);
      inc(src);
      inc(dest);
    end;
  end;
end;

procedure _24_to_32(src:p24;dest:pbyte;w,h,spitch,dpitch:integer);
var
  x,y:integer;
  os:p24;
  od:pbyte;
begin
  os:=src;od:=dest;
  for y:=0 to h-1 do begin
    src:=pointer(longint(os)+y*spitch);
    dest:=pointer(longint(od)+y*dpitch);
    for x:=0 to w-1 do begin
      dest^:=src^.r;inc(dest);
      dest^:=src^.g;inc(dest);
      dest^:=src^.b;inc(dest);
      dest^:=0;inc(dest);
      inc(src);
    end;
  end;
end;

procedure _16_to_24(src:pword;dest:p24;w,h,spitch,dpitch:integer);
var
  x,y:integer;
  os:pword;
  od:p24;
begin
  os:=src;od:=dest;
  for y:=0 to h-1 do begin
    src:=pointer(longint(os)+y*spitch);
    dest:=pointer(longint(od)+y*dpitch);
    for x:=0 to w-1 do begin
      dest^.r:=src^ and $1F*8;
      dest^.g:=(src^ and $7E0 shr 5)*4;
      dest^.b:=(src^ and $F800 shr 11)*8;
      inc(src);
      inc(dest);
    end;
  end;
end;

procedure _32_to_24(src:pbyte;dest:p24;w,h,spitch,dpitch:integer);
var
  x,y:integer;
  os:pbyte;
  od:p24;
begin
  os:=src;od:=dest;
  for y:=0 to h-1 do begin
    src:=pointer(longint(os)+y*spitch);
    dest:=pointer(longint(od)+y*dpitch);
    for x:=0 to w-1 do begin
      dest^.r:=src^;inc(src);
      dest^.g:=src^;inc(src);
      dest^.b:=src^;inc(src);
      inc(dest);
      inc(src);
    end;
  end;
end;

procedure _8_to_16(src:pbyte;dest:pword;w,h,spitch,dpitch:integer;var pal:vgapalette);
var
  x,y:integer;
  os:pbyte;
  od:pword;
begin
  os:=src;od:=dest;
  for y:=0 to h-1 do begin
    src:=pointer(longint(os)+y*spitch);
    dest:=pointer(longint(od)+y*dpitch);
    for x:=0 to w-1 do begin
      dest^:=((pal[src^].r div 2) shl 11) or (pal[src^].g shl 5) or (pal[src^].b div 2);
      inc(src);
      inc(dest);
    end;
  end;
end;

procedure _8_to_24(src:pbyte;dest:p24;w,h,spitch,dpitch:integer;var pal:vgapalette);
var
  x,y:integer;
  os:pbyte;
  od:p24;
begin
  os:=src;od:=dest;
  for y:=0 to h-1 do begin
    src:=pointer(longint(os)+y*spitch);
    dest:=pointer(longint(od)+y*dpitch);
    for x:=0 to w-1 do begin
      dest^.b:=pal[src^].r*4;
      dest^.g:=pal[src^].g*4;
      dest^.r:=pal[src^].b*4;
      inc(dest);
      inc(src);
    end;
  end;
end;

procedure _8_to_32(src:pbyte;dest:pbyte;w,h,spitch,dpitch:integer;var pal:vgapalette);
var
  x,y:integer;
  os,od:pbyte;
begin
  os:=src;od:=dest;
  for y:=0 to h-1 do begin
    src:=pointer(longint(os)+y*spitch);
    dest:=pointer(longint(od)+y*dpitch);
    for x:=0 to w-1 do begin
      dest^:=pal[src^].b*4;inc(dest);
      dest^:=pal[src^].g*4;inc(dest);
      dest^:=pal[src^].r*4;inc(dest);
      dest^:=0;inc(dest);
      inc(src);
    end;
  end;
end;

procedure _32_to_16(src:pbyte;dest:pword;w,h,spitch,dpitch:integer);
var
  x,y,r,g,b:integer;
  os:pbyte;
  od:pword;
begin
  os:=src;od:=dest;
  for y:=0 to h-1 do begin
    src:=pointer(longint(os)+y*spitch);
    dest:=pointer(longint(od)+y*dpitch);
    for x:=0 to w-1 do begin
      r:=src^;inc(src);
      g:=src^;inc(src);
      b:=src^;inc(src);
      dest^:=((b div 8) shl 11) or ((g div 4) shl 5) or (r div 8);
      inc(dest);
      inc(src);
    end;
  end;
end;

procedure _16_to_32(src:pword;dest:pbyte;w,h,spitch,dpitch:integer);
var
  x,y:integer;
  os:pword;
  od:pbyte;
begin
  os:=src;od:=dest;
  for y:=0 to h-1 do begin
    src:=pointer(longint(os)+y*spitch);
    dest:=pointer(longint(od)+y*dpitch);
    for x:=0 to w-1 do begin
      dest^:=src^ and $1F*8;inc(dest);
      dest^:=(src^ and $7E0 shr 5)*4;inc(dest);
      dest^:=(src^ and $F800 shr 11)*8;inc(dest);
      inc(src);
      inc(dest);
    end;
  end;
end;

//conv.end

procedure PutSurfaceData(var srf:tsurface;src:pvidmem;sbpp,spitch:integer);overload;
var
  p:pvidmem;
  y:integer;
begin
  p:=Lock(srf);
  if vid_bpp=sbpp then begin
    for y:=0 to srf.h-1 do
      move(src^[y*spitch],p^[y*srf.pitch],srf.w*vid_bypp);
  end else case sbpp of
    16:if vid_bpp=32 then _16_to_32(pointer(src),pointer(p),srf.w,srf.h,spitch,srf.pitch);
    32:if vid_bpp=16 then _32_to_16(pointer(src),pointer(p),srf.w,srf.h,spitch,srf.pitch);
    24:begin
      if vid_bpp=16 then _24_to_16(pointer(src),pointer(p),srf.w,srf.h,spitch,srf.pitch);
      if vid_bpp=32 then _24_to_32(pointer(src),pointer(p),srf.w,srf.h,spitch,srf.pitch);
    end;
  end;
  UnLock(srf);
end;

procedure PutSurfaceData(var srf:tsurface;src:pvidmem;sbpp,spitch:integer;var pal:vgapalette);overload;
var
  p:pvidmem;
begin
  if vid_bpp=sbpp then PutSurfaceData(srf,src,sbpp,spitch) else begin
    if sbpp=8 then begin
      p:=Lock(srf);
      case vid_bpp of
        16:_8_to_16(pointer(src),pointer(p),srf.w,srf.h,spitch,srf.pitch,pal);
        32:_8_to_32(pointer(src),pointer(p),srf.w,srf.h,spitch,srf.pitch,pal);
      end;
      Unlock(srf);
    end else PutSurfaceData(srf,src,sbpp,spitch);
  end;
end;

procedure GetSurfaceData(var srf:tsurface;dest:pvidmem;dbpp,dpitch:integer);overload;
var
  y:integer;
  p:pvidmem;
begin
  p:=Lock(srf);
  if vid_bpp=dbpp then begin
    for y:=0 to srf.h-1 do
      move(p^[y*srf.pitch],dest^[y*dpitch],srf.w*vid_bypp);
  end else case dbpp of
    16:if vid_bpp=32 then _32_to_16(pointer(p),pointer(dest),srf.w,srf.h,srf.pitch,dpitch);
    32:if vid_bpp=16 then _16_to_32(pointer(p),pointer(dest),srf.w,srf.h,srf.pitch,dpitch);
    24:begin
      if vid_bpp=16 then _16_to_24(pointer(p),pointer(dest),srf.w,srf.h,srf.pitch,dpitch);
      if vid_bpp=32 then _32_to_24(pointer(p),pointer(dest),srf.w,srf.h,srf.pitch,dpitch);
    end;
  end;
  UnLock(srf);
end;

procedure GetSurfaceData(var srf:tsurface;dest:pvidmem;dbpp,dpitch:integer;var pal:vgapalette);overload;
var
  p:pvidmem;
begin
  if vid_bpp=dbpp then GetSurfaceData(srf,dest,dbpp,dpitch) else begin
    if vid_bpp=8 then begin
      p:=Lock(srf);
      case dbpp of
        16:_8_to_16(pointer(p),pointer(dest),srf.w,srf.h,srf.pitch,dpitch,pal);
        24:_8_to_24(pointer(p),pointer(dest),srf.w,srf.h,srf.pitch,dpitch,pal);
        32:_8_to_32(pointer(p),pointer(dest),srf.w,srf.h,srf.pitch,dpitch,pal);
      end;
      Unlock(srf);
    end else GetSurfaceData(srf,dest,dbpp,dpitch);
  end;
end;

function CalcRGB(r,g,b:byte):longint;
begin
  if vid_bpp=32 then begin
    result:=(r shl vid_rshift) or (g shl vid_gshift) or (b shl vid_bshift);
  end else begin
    result:=((r and $1F) shl vid_rshift) or ((g and $3F) shl vid_gshift) or ((b and $1F) shl vid_bshift);
  end;
end;

function GetR(col:longint):byte;
begin
  result:=(col and vid_rmask);
end;

function GetG(col:longint):byte;
begin
  result:=(col and vid_gmask);
end;

function GetB(col:longint):byte;
begin
  result:=(col and vid_bmask);
end;

procedure GetRGB(col:longint;var r,g,b:byte);
begin
  r:=GetR(col);
  g:=GetG(col);
  b:=GetB(col);
end;

var
  vp:pvidmem;

procedure gclrscr(var srf:tsurface;color:longint);
var
  x,y:integer;
begin
  vp:=lock(srf);
  if vid_bpp=8 then begin
    for y:=0 to srf.h-1 do fillchar(vp^[y*srf.pitch],srf.w,color);
  end else begin
    for y:=0 to srf.h-1 do
      for x:=0 to srf.w-1 do
        move(color,vp^[x*vid_bypp+y*srf.pitch],vid_bypp);
  end;
  unlock(srf);
end;

procedure PutPixel(var dest:TSurface;x,y:integer;color:longint);
begin
  if (x>=0) and (y>=0) and (x<dest.w) and (y<dest.h) then begin
    vp:=lock(dest);
    if vid_bpp=8 then vp^[x+y*dest.pitch]:=color else
      move(color,vp^[x*vid_bypp+y*dest.pitch],vid_bypp);
    unlock(dest);
  end;
end;

function GetPixel(var src:TSurface;x,y:integer):longint;
begin
  if (x>=0) and (y>=0) and (x<src.w) and (y<src.h) then begin
    vp:=lock(src);
    if vid_bpp=8 then result:=vp^[x+y*src.pitch] else
      move(vp^[x*vid_bypp+y*src.pitch],result,vid_bypp);
    unlock(src);
  end else result:=0;
end;

procedure hline(var dest:TSurface;x1,y,x2:integer;color:longint);
var
  x:integer;
begin
  if x1>x2 then begin
    x:=x1;
    x1:=x2;
    x2:=x;
  end;
  if x1>=dest.w then exit;
  if x1<0 then x1:=0;
  if y>=dest.h then exit;
  if y<0 then y:=0;
  if x2>=dest.w then x2:=dest.w-1;
  if x2<0 then exit;
  vp:=lock(dest);
  if vid_bpp=8 then begin
    for x:=x1 to x2 do vp^[x+y*dest.pitch]:=color;
  end else begin
    for x:=x1 to x2 do move(color,vp^[x*vid_bypp+y*dest.pitch],vid_bypp);
  end;
  unlock(dest);
end;

procedure vline(var dest:TSurface;x,y1,y2:integer;color:longint);
var
  y:integer;
begin
  if y1>y2 then begin
    y:=y1;
    y1:=y2;
    y2:=y;
  end;
  if y1>=dest.h then exit;
  if y1<0 then y1:=0;
  if x>=dest.w then exit;
  if x<0 then x:=0;
  if y2>=dest.h then y2:=dest.h-1;
  if y2<0 then exit;
  vp:=lock(dest);
  if vid_bpp=8 then begin
    for y:=y1 to y2 do vp^[x+y*dest.pitch]:=color;
  end else begin
    for y:=y1 to y2 do move(color,vp^[x*vid_bypp+y*dest.pitch],vid_bypp);
  end;
  unlock(dest);
end;

procedure DrawLine(var dest:TSurface;x1,y1,x2,y2:integer;color:longint);
var
  d,ax,ay,sx,sy,dx,dy:integer;
begin
  lock(dest); //to speed things up
  dx:=x2-x1;ax:=abs(dx)*2;if dx<0 then sx:=-1 else sx:=1;
  dy:=y2-y1;ay:=abs(dy)*2;if dy<0 then sy:=-1 else sy:=1;
  putpixel(dest,x1,y1,color);
  if ax>ay then begin
    d:=ay-ax div 2;
    while x1<>x2 do begin
      if d>=0 then begin inc(y1,sy);dec(d,ax);end;
      inc(x1,sx);
      inc(d,ay);
      putpixel(dest,x1,y1,color);
    end;
  end else begin
    d:=ax-ay div 2;
    while y1<>y2 do begin
      if d>=0 then begin inc(x1,sx);dec(d,ay);end;
      inc(y1,sy);
      inc(d,ax);
      putpixel(dest,x1,y1,color);
    end;
  end;
  unlock(dest);
end;

procedure DrawCircle(var dest:TSurface;xc,yc,r:integer;color:longint);
var
  x,y,d:integer;
begin
  lock(dest); //to speed things up
  x:=0;y:=r;d:=2*(1-r);
  while y>=0 do begin
    putpixel(dest,xc+x,yc+y,color);
    putpixel(dest,xc+x,yc-y,color);
    putpixel(dest,xc-x,yc+y,color);
    putpixel(dest,xc-x,yc-y,color);
    if d+y>0 then begin
      dec(y);
      dec(d,2*y+1);
    end;
    if x>d then begin
      inc(x);
      inc(d,2*x+1);
    end;
  end;
  unlock(dest);
end;

procedure DrawRectangle(var dest:TSurface;x1,y1,x2,y2:integer;color:longint);
var
  x,y:integer;
  drawuh,drawdh,drawlv,drawrv:boolean;
begin
  if x1>x2 then begin
    x:=x1;
    x1:=x2;
    x2:=x;
  end;
  if y1>y2 then begin
    y:=y1;
    y1:=y2;
    y2:=y;
  end;
  if x1>=dest.w then exit;
  if y1>=dest.h then exit;
  drawuh:=true;drawdh:=true;drawlv:=true;drawrv:=true;
  if x1<0 then begin
    x1:=0;
    drawlv:=false;
  end;
  if y1<0 then begin
    y1:=0;
    drawuh:=false;
  end;
  if x2>=dest.w then begin
    x2:=dest.w-1;
    drawrv:=false;
  end;
  if y2>=dest.h then begin
    y2:=dest.h-1;
    drawdh:=false;
  end;
  vp:=lock(dest);
  if drawuh then hline(dest,x1,y1,x2,color);
  if drawdh then hline(dest,x1,y2,x2,color);
  if drawlv then vline(dest,x1,y1,y2,color);
  if drawrv then vline(dest,x2,y1,y2,color);
  unlock(dest);
end;

procedure DrawFilledRectangle(var dest:TSurface;x1,y1,x2,y2:integer;color:longint);
var
  x,y:integer;
begin
  if x1>x2 then begin
    x:=x1;
    x1:=x2;
    x2:=x;
  end;
  if y1>y2 then begin
    y:=y1;
    y1:=y2;
    y2:=y;
  end;
  if x1>=dest.w then exit;
  if y1>=dest.h then exit;
  if x1<0 then x1:=0;
  if y1<0 then y1:=0;
  if x2>=dest.w then x2:=dest.w-1;
  if y2>=dest.h then y2:=dest.h-1;
  vp:=lock(dest);
  if vid_bpp=8 then begin
    for y:=y1 to y2 do fillchar(vp^[x1+y*dest.pitch],x2-x1+1,color);
  end else begin
    for y:=y1 to y2 do
      for x:=x1 to x2 do
        move(color,vp^[x*vid_bypp+y*dest.pitch],vid_bypp);
  end;
  unlock(dest);
end;

procedure DrawBox(var dest:TSurface;x1,y1,x2,y2:integer;f1c,f2c,bc,t:longint);
begin
  case t of
    1:begin
      hline(dest,x1,y1+1,x2,f2c);
      vline(dest,x1+1,y1,y2,f2c);
      hline(dest,x1,y2-1,x2-1,f2c);
      vline(dest,x2-1,y1,y2-1,f2c);
      hline(dest,x1,y1+1,x2-1,f1c);
      vline(dest,x1+1,y1,y2-1,f1c);
      DrawFilledRectangle(dest,x1+2,y1+2,x2-2,y2-2,bc);
    end;
    0:DrawFilledRectangle(dest,x1+1,y1+1,x2-1,y2-1,bc);
  end;
  hline(dest,x1,y2,x2,f2c);
  vline(dest,x2,y1,y2,f2c);
  hline(dest,x1,y1,x2,f1c);
  vline(dest,x1,y1,y2,f1c);
end;

//imagefileloadsave.start

type
  TPCXHeader=packed record
    Manufacturer:byte;
    Version:byte;
    Encoding:byte;
    BitsPerPixel:byte;
    XMin:word;
    YMin:word;
    XMax:word;
    YMax:word;
    HRes:word;
    VRes:word;
    ColorMap:array [1..48] of byte;
    Reserved:byte;
    NPlanes:byte;
    BytesPerLine:word;
    PaletteInfo:word;
    XSize:word;
    YSize:word;
    Filler:array [1..54] of byte;
  end;

  TBMPHeader=packed record
    id:word;
    fsiz:longint;
    reserved:longint;
    bmpofs:longint;
    bmpinfohdrlen:longint;
    xsize:longint;
    ysize:longint;
    nplanes:word;
    bpp:word;
    comptype:longint;
    imgsiz:longint;
    hres:longint;
    vres:longint;
    nusedcolors:longint;
    nimportantcolors:longint;
  end;

const
  BMP_ID=$4D42;
  PCX_ID=10;
  PCX_VER=5;
  PCX_PAL256_ID=12;

function LoadPCX8(filename:string;var destpal:vgapalette):TSurface;overload;
var
  hdr:tpcxheader;
  f:longint;
  xs,x,y,i:integer;
  sz,b:byte;
  buf:pvidmem;
begin
  result.w:=0;result.h:=0;
  f:=ff.open(filename);
  if f=0 then exit;
  ff.read(f,hdr,128);
  if (hdr.Manufacturer<>PCX_ID) or (hdr.Version<>PCX_VER) then begin
    ff.close(f);
    exit;
  end;
  xs:=hdr.XMax+1;
  ff.seek(f,-769,2);
  ff.read(f,b,1);
  if b<>PCX_PAL256_ID then begin
    ff.close(f);
    exit;
  end;
  ff.read(f,destpal,768);
  for i:=0 to 255 do begin
    destpal[i].r:=destpal[i].r div 4;
    destpal[i].g:=destpal[i].g div 4;
    destpal[i].b:=destpal[i].b div 4;
  end;
  MkSurface(result,xs,hdr.ymax+1,false,false,0);
  if vid_bpp=8 then _SetPal(result,destpal);
  GetMem(buf,result.w*result.h);
  x:=0;
  y:=0;
  ff.seek(f,128,0);
  While y<hdr.YMax+1 do begin
    ff.read(f,b,1);
    if (b and $c0)=$c0 then begin
      sz:=b and $3f;
      ff.read(f,b,1);
    end else sz:=1;
    for i:=1 to sz do begin
      buf^[x+y*xs]:=b;
      Inc(x);
      if x=hdr.XMax+1 then begin
        x:=0;
        Inc(y);
      end;
    end;
  end;
  PutSurfaceData(result,buf,8,result.w,destpal);
  FreeMem(buf);
  ff.close(f);
end;

function LoadPCX8(filename:string):TSurface;overload;
var
  tmp:vgapalette;
begin
  result:=LoadPCX8(filename,tmp);
end;

function SavePCX8(filename:string;var src:TSurface;var srcpal:vgapalette;x1,y1,x2,y2:integer):boolean;
var
  f:file;
  hdr:tpcxheader;
  i,x,y:longint;
  ch,runcount,runchar:byte;
  pal:vgapalette;
  p,buf:pvidmem;
begin
  result:=False;
  Assign(f,filename);
  try
    ReWrite(f,1);
  except
    Exit;
  end;
  hdr.Manufacturer:=PCX_ID;
  hdr.Version:=PCX_VER;
  hdr.Encoding:=1;
  hdr.BitsPerPixel:=8;
  hdr.XMin:=0;
  hdr.YMin:=0;
  hdr.XMax:=x2-x1;
  hdr.YMax:=y2-y1;
  hdr.HRes:=screen.w;
  hdr.VRes:=screen.h;
  hdr.Reserved:=0;
  hdr.NPlanes:=1;
  hdr.BytesPerLine:=x2-x1+1;
  hdr.PaletteInfo:=1;
  hdr.XSize:=x2-x1+1;
  hdr.YSize:=y2-y1+1;
  FillChar(hdr.ColorMap,48,0);
  FillChar(hdr.Filler,54,0);
  BlockWrite(f,hdr,128);
  GetMem(buf,src.w*src.h);
  p:=Lock(src);
  move(p^,buf^,src.w*src.h);
  Unlock(src);
  for y:=y1 to y2 do begin
    runcount:=0;
    runchar:=0;
    for x:=x1 to x2 do begin
      ch:=buf^[x+y*src.w];
      if runcount=0 then begin
        runcount:=1;
        runchar:=ch;
      end else begin
        if (ch<>runchar) or (runcount>=$3f) then begin
          if (runcount>1) or (runchar and $c0=$c0) then begin
            i:=runcount or $c0;
            BlockWrite(f,i,1);
          end;
          BlockWrite(f,runchar,1);
          runcount:=1;
          runchar:=ch;
        end else Inc(runcount);
      end;
    end;
    if (runcount>1) or (runchar and $c0=$c0) then begin
      i:=runcount or $c0;
      BlockWrite(f,i,1);
    end;
    BlockWrite(f,runchar,1);
  end;
  FreeMem(buf);
  move(srcpal,pal,sizeof(pal));
  ch:=PCX_PAL256_ID;
  BlockWrite(f,ch,1);
  for i:=0 to 255 do begin
    pal[i].r:=pal[i].r*4;
    pal[i].g:=pal[i].g*4;
    pal[i].b:=pal[i].b*4;
  end;
  BlockWrite(f,pal,768);
  Close(f);
  result:=True;
end;

function LoadBMP8(filename:string;var destpal:vgapalette):TSurface;overload;
var
  f:longint;
  hdr:tbmpheader;
  i,y:integer;
  b:byte;
  buf:pvidmem;
begin
  result.w:=0;result.h:=0;
  f:=ff.open(filename);
  if f=0 then exit;
  ff.read(f,hdr,SizeOf(hdr));
  if (hdr.id<>BMP_ID) or (hdr.comptype<>0) or (hdr.bpp<>8) then begin
    ff.close(f);
    exit;
  end;
  for i:=0 to 255 do begin
    ff.read(f,destpal[i].b,1);
    destpal[i].b:=destpal[i].b div 4;
    ff.read(f,destpal[i].g,1);
    destpal[i].g:=destpal[i].g div 4;
    ff.read(f,destpal[i].r,1);
    destpal[i].r:=destpal[i].r div 4;
    ff.read(f,b,1);
  end;
  MkSurface(result,hdr.xsize,hdr.ysize,false,false,0);
  if vid_bpp=8 then _SetPal(result,destpal);
  GetMem(buf,result.w*result.h);
  for y:=hdr.ysize-1 downto 0 do begin
    ff.read(f,buf^[y*hdr.xsize],hdr.xsize);
    if hdr.xsize mod 4<>0 then ff.seek(f,abs(4-(hdr.xsize mod 4)),1);
  end;
  PutSurfaceData(result,buf,8,result.w,destpal);
  FreeMem(buf);
  ff.close(f);
end;

function LoadBMP8(filename:string):TSurface;overload;
var
  tmp:vgapalette;
begin
  result:=LoadBMP8(filename,tmp);
end;

var
  sbmp24pal:vgapalette;

function SaveBMP8(filename:string;var src:TSurface;var srcpal:vgapalette;x1,y1,x2,y2:integer):boolean;
var
  f:file;
  hdr:tbmpheader;
  pal:vgapalette;
  i:integer;
  y:longint;
  p,buf:pvidmem;
begin
  result:=False;
  Assign(f,filename);
  try
    ReWrite(f,1);
  except
    Exit;
  end;
  hdr.id:=BMP_ID;
  hdr.reserved:=0;
  hdr.bmpofs:=SizeOf(hdr)+768+256;
  hdr.bmpinfohdrlen:=40;
  hdr.xsize:=(x2-x1)+1;
  hdr.ysize:=(y2-y1)+1;
  hdr.nplanes:=1;
  hdr.bpp:=8;
  hdr.comptype:=0;
  hdr.imgsiz:=hdr.xsize*hdr.ysize;
  hdr.hres:=screen.w;
  hdr.vres:=screen.h;
  hdr.nusedcolors:=0;
  hdr.nimportantcolors:=0;
  BlockWrite(f,hdr,SizeOf(hdr));
  move(srcpal,pal,768);
  for i:=0 to 255 do begin
    pal[i].r:=pal[i].r*4;
    pal[i].g:=pal[i].g*4;
    pal[i].b:=pal[i].b*4;
    BlockWrite(f,pal[i].b,1);
    BlockWrite(f,pal[i].g,1);
    BlockWrite(f,pal[i].r,1);
    BlockWrite(f,hdr.reserved,1);
  end;
  GetMem(buf,src.w*src.h);
  p:=Lock(src);
  move(p^,buf^,src.w*src.h);
  Unlock(src);
  for y:=y2 downto y1 do begin
    BlockWrite(f,buf^[x1+y*src.w],hdr.xsize);
    if hdr.xsize mod 4<>0 then BlockWrite(f,i,abs(4-(hdr.xsize mod 4)));
  end;
  FreeMem(buf);
  hdr.fsiz:=FileSize(f);
  Seek(f,0);
  BlockWrite(f,hdr,SizeOf(hdr));
  Close(f);
  result:=True;
end;

function LoadBMP24(filename:string):TSurface;
var
  f:longint;
  hdr:tbmpheader;
  xs,y:integer;
  buf:pvidmem;
begin
  result.w:=0;result.h:=0;
  f:=ff.open(filename);
  if f=0 then exit;
  ff.read(f,hdr,SizeOf(hdr));
  if (hdr.id<>BMP_ID) or (hdr.comptype<>0) or (hdr.bpp<>24) then begin
    ff.close(f);
    exit;
  end;
  ff.seek(f,hdr.bmpofs,0);
  MkSurface(result,hdr.xsize,hdr.ysize,false,false,0);
  GetMem(buf,result.w*result.h*3);
  xs:=hdr.xsize*3;
  for y:=hdr.ysize-1 downto 0 do begin
    ff.read(f,buf^[y*xs],xs);
    if xs mod 4<>0 then ff.seek(f,abs(4-(xs mod 4)),1);
  end;
  ff.close(f);
  PutSurfaceData(result,buf,24,xs);
  FreeMem(buf);
end;

function SaveBMP24(filename:string;var src:TSurface;x1,y1,x2,y2:integer):boolean;overload;
var
  f:file;
  hdr:tbmpheader;
  i,y,xs:longint;
  buf:pvidmem;
begin
  result:=False;
  Assign(f,filename);
  try
    ReWrite(f,1);
  except
    Exit;
  end;
  hdr.id:=BMP_ID;
  hdr.reserved:=0;
  hdr.bmpofs:=SizeOf(hdr);
  hdr.bmpinfohdrlen:=40;
  hdr.xsize:=(x2-x1)+1;
  hdr.ysize:=(y2-y1)+1;
  hdr.nplanes:=1;
  hdr.bpp:=24;
  hdr.comptype:=0;
  hdr.imgsiz:=hdr.xsize*hdr.ysize*3;
  hdr.hres:=screen.w;
  hdr.vres:=screen.h;
  hdr.nusedcolors:=0;
  hdr.nimportantcolors:=0;
  BlockWrite(f,hdr,SizeOf(hdr));
  GetMem(buf,src.w*src.h*3);
  if vid_bpp<>8 then GetSurfaceData(src,buf,24,src.w*3) else
    GetSurfaceData(src,buf,24,src.w*3,sbmp24pal);
  xs:=hdr.xsize*3;
  for y:=y2 downto y1 do begin
    BlockWrite(f,buf^[(x1+y*src.w)*3],xs);
    if hdr.xsize mod 4<>0 then BlockWrite(f,i,abs(4-(xs mod 4)));
  end;
  FreeMem(buf);
  hdr.fsiz:=FileSize(f);
  Seek(f,0);
  BlockWrite(f,hdr,SizeOf(hdr));
  Close(f);
  result:=True;
end;

function SaveBMP24(filename:string;var src:TSurface;x1,y1,x2,y2:integer;var srcpal:vgapalette):boolean;overload;
begin
  move(srcpal,sbmp24pal,768);
  result:=SaveBMP24(filename,src,x1,y1,x2,y2);
end;

//imagefileloadsave.end

//textout.start

procedure DrawChar(var dest:TSurface;var fnt;x,y:integer;ch:char;fc,bc:longint;ovr:boolean;cxsiz,cysiz:byte);
const
  btab:array [0..7] of byte=(128,64,32,16,8,4,2,1);
var
  dst,p:pvidmem;
  linelen,i,j,z,b,c:integer;
begin
  dst:=Lock(dest);
  linelen:=cxsiz div 8;
  if cxsiz mod 8<>0 then inc(linelen);
  for i:=0 to cysiz-1 do begin
    if y+i>=dest.h then break;
    p:=pointer(longint(@fnt)+ord(ch)*cysiz*linelen+i*linelen);
    z:=0;
    j:=0;
    c:=p^[j];
    for b:=cxsiz-1 downto 0 do begin
      if x+z>=dest.w then break;
      if (b+1) mod 8=0 then begin
        c:=p^[j];
        inc(j);
      end;
      if (c and btab[z mod 8])<>0 then
        move(fc,dst^[(x+z)*vid_bypp+(y+i)*dest.pitch],vid_bypp) else
          if ovr then move(bc,dst^[(x+z)*vid_bypp+(y+i)*dest.pitch],vid_bypp);
      inc(z);
    end;
  end;
  Unlock(dest);
end;

procedure DrawStr(var dest:TSurface;var fnt;x,y:integer;s:string;fc,bc:longint;ovr:boolean;cxsiz,cysiz:byte);
var
  i:integer;
begin
  for i:=1 to length(s) do
    drawchar(dest,fnt,x+(i-1)*cxsiz,y,s[i],fc,bc,ovr,cxsiz,cysiz);
end;

procedure DrawStr8x16Ovr8(dest:pointer;var fnt;x,y,w:integer;const s:shortstring;fc,bc:longint);assembler;pascal;
asm
  push esi
  push edi
  cld
  mov edx,s
  xor ecx,ecx
  mov cl,byte ptr [edx]
  cmp ecx,0
  je @end
  mov edi,dest
  mov eax,y
  push edx
  mul w
  pop edx
  add eax,x //*
  add edi,eax
@charloop:
  inc edx
  xor eax,eax
  mov al,byte ptr [edx]
  shl eax,4
  mov esi,fnt
  add esi,eax  
  push edi
  push ecx
  mov ch,16
@l1:
  lodsb
  mov cl,8
@l2:
  shl al,1
  jnc @l3
  mov ah,fc.byte
  mov [edi],ah //*
  jmp @l4
@l3:
  mov ah,bc.byte
  mov [edi],ah //*
@l4:
  inc edi //*
  dec cl
  jnz @l2
  add edi,w
  sub edi,8 //*
  dec ch
  jnz @l1
  pop ecx
  pop edi
  add edi,8 //*
  loop @charloop
@end:
  pop edi
  pop esi
end;

procedure DrawStr8x16Ovr16(dest:pointer;var fnt;x,y,w:integer;const s:shortstring;fc,bc:longint);assembler;pascal;
asm
  push ebx
  push esi
  push edi
  cld
  mov edx,s
  xor ecx,ecx
  mov cl,byte ptr [edx]
  cmp ecx,0
  je @end
  mov edi,dest
  mov eax,y
  push edx
  mul w
  mov ebx,x
  imul ebx,2 //*
  pop edx
  add eax,ebx
  add edi,eax
@charloop:
  inc edx
  xor eax,eax
  mov al,byte ptr [edx]
  shl eax,4
  mov esi,fnt
  add esi,eax  
  push edi
  push ecx
  mov ch,16
@l1:
  lodsb
  mov cl,8
@l2:
  shl al,1
  jnc @l3
  mov bx,fc.word
  mov [edi],bx //*
  jmp @l4
@l3:
  mov bx,bc.word
  mov [edi],bx //*
@l4:
  add edi,2 //*
  dec cl
  jnz @l2
  add edi,w
  sub edi,16 //*
  dec ch
  jnz @l1
  pop ecx
  pop edi
  add edi,16 //*
  loop @charloop
@end:
  pop edi
  pop esi
  pop ebx
end;

procedure DrawStr8x16Ovr32(dest:pointer;var fnt;x,y,w:integer;const s:shortstring;fc,bc:longint);assembler;pascal;
asm
  push ebx
  push esi
  push edi
  cld
  mov edx,s
  xor ecx,ecx
  mov cl,byte ptr [edx]
  cmp ecx,0
  je @end
  mov edi,dest
  mov eax,y
  push edx
  mul w
  mov ebx,x
  imul ebx,4 //*
  pop edx
  add eax,ebx
  add edi,eax
@charloop:
  inc edx
  xor eax,eax
  mov al,byte ptr [edx]
  shl eax,4
  mov esi,fnt
  add esi,eax  
  push edi
  push ecx
  mov ch,16
@l1:
  lodsb
  mov cl,8
@l2:
  shl al,1
  jnc @l3
  mov ebx,fc
  mov [edi],ebx //*
  jmp @l4
@l3:
  mov ebx,bc
  mov [edi],ebx //*
@l4:
  add edi,4 //*
  dec cl
  jnz @l2
  add edi,w
  sub edi,32 //*
  dec ch
  jnz @l1
  pop ecx
  pop edi
  add edi,32 //*
  loop @charloop
@end:
  pop edi
  pop esi
  pop ebx
end;

//textout.end

//grs.start

const
  grsid:array [0..3] of char='GRSA';

function LoadGrs(filename:string;var grs:TGrs):boolean;
var
  f:longint;
  id:array [0..3] of char;
  i,y,csize,bypp:integer;
  comptype,cdepth:word;
  lbuf,buf:pvidmem;
begin
  result:=false;
  f:=ff.open(filename);
  if f=0 then exit;
  ff.read(f,id,4);
  if id<>grsid then begin
    ff.close(f);
    exit;
  end;
  ff.read(f,grs.n,4);
  ff.read(f,grs.pal,768);
  setlength(grs.w,grs.n+1);
  setlength(grs.h,grs.n+1);
  setlength(grs.img,grs.n+1);
  getmem(lbuf,64000);
  for i:=1 to grs.n do begin
    ff.read(f,grs.w[i],4);
    ff.read(f,grs.h[i],4);
    ff.read(f,comptype,2);
    ff.read(f,cdepth,2);
    if cdepth=0 then begin
      cdepth:=8;
      grs.is8bpp:=true;
    end;
    if cdepth=1 then begin
      cdepth:=24;
      grs.is8bpp:=false;
    end;
    bypp:=cdepth div 8;
    ff.read(f,csize,4);
    getmem(buf,grs.w[i]*grs.h[i]*bypp);
    for y:=0 to grs.h[i]-1 do begin
      ff.read(f,csize,4);
      ff.read(f,lbuf^,csize);
      rledecompress(lbuf^,buf^[y*grs.w[i]*bypp],csize);
    end;
    MkSurface(grs.img[i],grs.w[i],grs.h[i],false,true,255);
    if vid_bpp=8 then _SetPal(grs.img[i],grs.pal);
    if (cdepth=8) and (vid_bpp<>8) then
      PutSurfaceData(grs.img[i],buf,cdepth,grs.w[i]*bypp,grs.pal) else
      PutSurfaceData(grs.img[i],buf,cdepth,grs.w[i]*bypp);
    freemem(buf);
  end;
  freemem(lbuf);
  ff.close(f);
  result:=true;
end;

procedure UnloadGrs(var grs:TGrs);
var
  i:integer;
begin
  grs.w:=nil;
  grs.h:=nil;
  for i:=1 to grs.n do RmSurface(grs.img[i]);
  grs.img:=nil;
end;

function SaveGrs(filename:string;var grs:TGrs):boolean;
var
  f:file;
  i,y,csize,bypp,l:integer;
  comptype,cdepth:word;
  buf:pvidmem;
  lbuf:pointer;
begin
  result:=false;
  assign(f,filename);
  {$I-}
  rewrite(f,1);
  {$I+}
  if ioresult<>0 then exit;
  blockwrite(f,grsid,4);
  blockwrite(f,grs.n,4);
  blockwrite(f,grs.pal,768);
  comptype:=0;
  if grs.is8bpp then cdepth:=8 else cdepth:=24;
  bypp:=cdepth div 8;
  getmem(lbuf,$FFFF);
  for i:=1 to grs.n do begin
    blockwrite(f,grs.w[i],4);
    blockwrite(f,grs.h[i],4);
    blockwrite(f,comptype,2);
    l:=0;
    if cdepth=24 then l:=1;
    blockwrite(f,l,2);
    csize:=0;
    blockwrite(f,csize,4); //only available later
    getmem(buf,grs.w[i]*grs.h[i]*bypp);
    getsurfacedata(grs.img[i],buf,cdepth,grs.w[i]*bypp);
    for y:=0 to grs.h[i]-1 do begin
      l:=rlecompress(buf^[y*grs.w[i]*bypp],lbuf^,grs.w[i]*bypp);
      blockwrite(f,l,4);
      blockwrite(f,lbuf^,l);
      inc(csize,l+4);
    end;
    seek(f,filepos(f)-csize-4);
    blockwrite(f,csize,4);
    seek(f,filepos(f)+csize);
    freemem(buf);
  end;
  freemem(lbuf);
  close(f);
  result:=true;
end;

//grs.end

//fli.start

const
  FLI_ID=$AF11;
  FLI_FRAME_ID=$F1FA;
  FLI_COLOR=11;FLI_LC=12;FLI_BLACK=13;FLI_BRUN=15;FLI_COPY=16;

type
  TFLIHeader=packed record
    fsiz:longint;
    magic:word;
    frames:word;
    width:word;
    height:word;
    flags:longint;
    speed:word;
    next:longint;
    frit:longint;
    expand:array [1..102] of byte;
  end;

  TFLIFrameHeader=packed record
    framesiz:longint;
    magic:word;
    chunks:word;
    expand:array [1..8] of byte;
  end;

var
  fli_scrp:pvidmem;

function FLIPlayFrame(x1,y1,x2,y2,sx,sy:integer;frameptr:pointer;fhdr:tfliframeheader):boolean;
var
  firstline,lines,packets,x,y,i,j,z,chunktype,curchunk,frofs:longint;
  skipcount,r,g,b,clrskip,clrchange:byte;
  sizecount:shortint;
function GetByte:byte;assembler;
asm
  mov edx,frameptr
  add edx,frofs
  mov al,byte ptr [edx]
  inc frofs
end;
function GetWord:word;assembler;
asm
  mov edx,frameptr
  add edx,frofs
  mov ax,word ptr [edx]
  inc frofs
  inc frofs
end;
function GetLong:longint;assembler;
asm
  mov edx,frameptr
  add edx,frofs
  mov eax,[edx]
  add frofs,4
end;
begin
  result:=True;
  frofs:=0;
  for curchunk:=1 to fhdr.chunks do begin
    GetLong; //chunksize
    chunktype:=GetWord;
    case chunktype of
      FLI_COLOR:begin
        packets:=GetWord;
        for i:=1 to packets do begin
          clrskip:=GetByte;
          clrchange:=GetByte;
          if clrchange=0 then j:=256 else j:=clrchange;
          for z:=clrskip to clrskip+j-1 do begin
            r:=GetByte;
            g:=GetByte;
            b:=GetByte;
            screenpal[z].r:=r;screenpal[z].g:=g;screenpal[z].b:=b;
          end;
          SetPal(screenpal);
        end;
      end;
      FLI_LC:begin
        firstline:=GetWord;
        lines:=GetWord;
        for y:=firstline to firstline+lines-1 do begin
          x:=0;
          packets:=GetByte;
          for z:=1 to packets do begin
            skipcount:=GetByte;
            sizecount:=GetByte;
            Inc(x,skipcount);
            if sizecount>0 then begin
              for i:=1 to sizecount do begin
                b:=GetByte;
                if (x>=x1) and (x<=x2) then
                  if (y>=y1) and (y<=y2) then
                    fli_scrp^[sx+x+(y+sy)*screen.pitch]:=b;
                Inc(x);
              end;
            end else begin
              b:=GetByte;
              for i:=1 to abs(sizecount) do begin
                if (x>=x1) and (x<=x2) then
                  if (y>=y1) and (y<=y2) then
                    fli_scrp^[sx+x+(y+sy)*screen.pitch]:=b;
                Inc(x);
              end;
            end;
          end;
        end;
      end;
      FLI_BLACK:begin
        for y:=y1 to y2 do
          for x:=x1 to x2 do
            fli_scrp^[sx+x+(y+sy)*screen.pitch]:=0;
      end;
      FLI_BRUN:begin
        for y:=0 to 199 do begin
          x:=0;
          packets:=GetByte;
          for i:=1 to packets do begin
            sizecount:=GetByte;
            if sizecount>0 then begin
              b:=GetByte;
              for z:=1 to sizecount do begin
                if (x>=x1) and (x<=x2) then
                  if (y>=y1) and (y<=y2) then
                    fli_scrp^[sx+x+(y+sy)*screen.pitch]:=b;
                Inc(x);
              end;
            end else begin
              for z:=1 to abs(sizecount) do begin
                b:=GetByte;
                if (x>=x1) and (x<=x2) then
                  if (y>=y1) and (y<=y2) then
                    fli_scrp^[sx+x+(y+sy)*screen.pitch]:=b;
                Inc(x);
              end;
            end;
          end;
        end;
      end;
      FLI_COPY:begin
        for y:=y1 to y2 do
          for x:=x1 to x2 do
            fli_scrp^[sx+x+(y+sy)*screen.pitch]:=GetByte;
      end;
      else begin
        result:=False;
        Exit;
      end;
    end;
  end;
end;

function PlayFLI(filename:string;x1,y1,x2,y2,sx,sy:integer;loop:boolean;maxloop:integer):boolean;
var
  f:longint;
  hdr:tfliheader;
  fhdr:tfliframeheader;
  frameptr:pointer;
  i,curframe:word;
  b:boolean;
begin
  result:=false;
  if vid_bpp<>8 then exit; //only works in 256 color modes
  f:=ff.open(filename);
  if f=0 then exit;
  if not loop then maxloop:=1;
  ff.read(f,hdr,sizeof(hdr));
  if hdr.magic=FLI_ID then begin
    if (hdr.width=320) and (hdr.height=200) then begin
      if hdr.frames<=4000 then begin
        while maxloop>0 do begin
          for curframe:=1 to hdr.frames do begin
            ff.read(f,fhdr,sizeof(fhdr));
            if fhdr.magic=FLI_FRAME_ID then begin
              if fhdr.framesiz<=65535 then begin
                GetMem(frameptr,fhdr.framesiz-SizeOf(fhdr));
                ff.read(f,frameptr^,fhdr.framesiz-SizeOf(fhdr));
                fli_scrp:=Lock(screen);
                b:=FLIPlayFrame(x1,y1,x2,y2,sx,sy,frameptr,fhdr);
                Unlock(screen);
                pupdate(0,0,0,0);
                FreeMem(frameptr,fhdr.framesiz-SizeOf(fhdr));
                if not b then begin
                  ff.close(f);
                  exit;
                end;
                Idle;
                for i:=1 to hdr.speed do WaitRetrace;
                if keypress then begin
                  rkey;
                  maxloop:=0;
                  break;
                end;
                if mustquit then begin
                  maxloop:=0;
                  break;
                end;
              end else begin
                ff.close(f);
                exit;
              end;
            end else begin
              ff.close(f);
              exit;
            end;
          end;
          ff.seek(f,SizeOf(hdr),0);
          if maxloop>0 then if not loop then Dec(maxloop) else
            if maxloop<>$FFFF then Dec(maxloop);
        end;
      end;
    end;
  end;
  ff.close(f);
  result:=True;
end;

//fli.end

initialization
  ag_platform_id:='alpgraph';
  default_ff.open:=_ff_open;
  default_ff.close:=_ff_close;
  default_ff.read:=_ff_read;
  default_ff.seek:=_ff_seek;
  SetFileFuncs(default_ff);

finalization
  if ag_inited then AGDone;
  if assigned(saved_screen) then freemem(saved_screen);
  initcallbacks:=nil;

end.
