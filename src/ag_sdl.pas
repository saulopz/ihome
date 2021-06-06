{ low-level part of alpgraph (SDL) }
{ (C) 2001 Laszlo Agocs (alp@dwp42.org) }

unit ag_sdl;

interface

uses sdl,alpgraph;

procedure register_ag_sdl;

implementation

type
  pss=psdl_surface;

var
  symkeybuf:array [1..128+1] of record //128 keypress at once should be enough
    sym:integer;
    modif:integer;
  end;

  sdlcursor:pSDL_Cursor; //pointer to SDL mouse cursor structure
  defcursor:pSDL_Cursor; //default SDL mouse cursor

  mousedata,mousemask:array [0..31] of byte;

  scantab:array [0..sdlk_last] of byte;

procedure mkscantab;
begin
  scantab[8]:=14;
  scantab[9]:=15;
  scantab[13]:=28;
  scantab[27]:=1;
  scantab[32]:=57;
  scantab[33]:=2;
  scantab[34]:=40;
  scantab[35]:=4;
  scantab[36]:=5;
  scantab[38]:=7;
  scantab[39]:=40;
  scantab[43]:=13;
  scantab[44]:=51;
  scantab[45]:=12;
  scantab[46]:=52;
  scantab[47]:=53;
  scantab[48]:=11;
  scantab[49]:=2;
  scantab[50]:=3;
  scantab[51]:=4;
  scantab[52]:=5;
  scantab[53]:=6;
  scantab[54]:=7;
  scantab[55]:=8;
  scantab[56]:=9;
  scantab[57]:=10;
  scantab[58]:=39;
  scantab[59]:=39;
  scantab[60]:=51;
  scantab[61]:=13;
  scantab[62]:=52;
  scantab[63]:=53;
  scantab[64]:=3;
  scantab[91]:=26;
  scantab[92]:=43;
  scantab[93]:=27;
  scantab[94]:=5;
  scantab[95]:=12;
  scantab[96]:=41;
  scantab[97]:=30;
  scantab[98]:=48;
  scantab[99]:=46;
  scantab[100]:=32;
  scantab[101]:=18;
  scantab[102]:=33;
  scantab[103]:=34;
  scantab[104]:=35;
  scantab[105]:=23;
  scantab[106]:=36;
  scantab[107]:=37;
  scantab[108]:=38;
  scantab[109]:=50;
  scantab[110]:=49;
  scantab[111]:=24;
  scantab[112]:=25;
  scantab[113]:=16;
  scantab[114]:=19;
  scantab[115]:=31;
  scantab[116]:=20;
  scantab[117]:=22;
  scantab[118]:=47;
  scantab[119]:=17;
  scantab[120]:=45;
  scantab[121]:=21;
  scantab[122]:=44;
  scantab[127]:=83;
  scantab[256]:=82;
  scantab[257]:=79;
  scantab[258]:=80;
  scantab[259]:=81;
  scantab[260]:=75;
  scantab[261]:=76;
  scantab[262]:=77;
  scantab[263]:=71;
  scantab[264]:=72;
  scantab[265]:=73;
  scantab[266]:=83;
  scantab[267]:=53;
  scantab[268]:=55;
  scantab[269]:=74;
  scantab[270]:=78;
  scantab[271]:=28;
  scantab[273]:=72;
  scantab[274]:=80;
  scantab[275]:=77;
  scantab[276]:=75;
  scantab[277]:=82;
  scantab[278]:=71;
  scantab[279]:=79;
  scantab[280]:=73;
  scantab[281]:=81;
  scantab[282]:=59;
  scantab[283]:=60;
  scantab[284]:=61;
  scantab[285]:=62;
  scantab[286]:=63;
  scantab[287]:=64;
  scantab[288]:=65;
  scantab[289]:=66;
  scantab[290]:=67;
  scantab[291]:=68;
  scantab[292]:=133;
  scantab[293]:=134;
  scantab[300]:=69;
  scantab[301]:=58;
  scantab[302]:=70;
  scantab[303]:=54;
  scantab[304]:=42;
  scantab[305]:=29;
  scantab[306]:=29;
  scantab[307]:=56;
  scantab[308]:=56;
  scantab[313]:=56;
end;

procedure sdlglUpdate(x1,y1,x2,y2:integer);
begin
  SDL_GL_SwapBuffers;
end;

procedure InitTimer;forward;
procedure DoneTimer;forward;

function sdlAGInit(xs,ys,bpp:integer;caption:ansistring;full,dblbuf:boolean):boolean;
var
  flags:cardinal;
  i:integer;
begin
  if not(bpp in [8,16,32]) then begin
    result:=false;
    exit;
  end;
  sdl_initsubsystem(sdl_init_video or sdl_init_timer);
  if bpp=8 then flags:=sdl_hwpalette else flags:=0;
  if dblbuf then flags:=flags or sdl_doublebuf;
  if full then flags:=flags or sdl_fullscreen;
  if (vid_flags and 1)<>0 then begin
    flags:=flags or sdl_opengl;
    Update:=sdlglUpdate;
    for i:=1 to 11 do
      if vid_ogl[i]<>-1 then SDL_GL_SetAttribute(i,vid_ogl[i]);
  end;
  screen.p:=sdl_setvideomode(xs,ys,bpp,flags);
  if assigned(screen.p) then begin
    inittimer;
    sdl_enablekeyrepeat(sdl_default_repeat_delay,sdl_default_repeat_interval);
    fillchar(keydown,sizeof(keydown),0);
    fillchar(symkeybuf,sizeof(symkeybuf),0);
    sdl_wm_setcaption(pchar(caption),pchar(caption));
    screen.w:=xs;
    screen.h:=ys;
    screen.transp:=false;
    screen.trans:=0;
    screen.hw:=((pss(screen.p)^.flags and sdl_hwsurface)<>0);
    vid_dblbuf:=((pss(screen.p)^.flags and sdl_doublebuf)<>0);
    defcursor:=sdl_getcursor;
    sdl_showcursor(0);
    vid_bpp:=bpp;
    vid_bypp:=(bpp+7) shr 3;
    vid_realbpp:=bpp;
    if vid_bpp=8 then setpal(pal_vga) else begin
      vid_rshift:=pss(screen.p)^.format^.rshift;
      vid_gshift:=pss(screen.p)^.format^.gshift;
      vid_bshift:=pss(screen.p)^.format^.bshift;
      vid_ashift:=pss(screen.p)^.format^.ashift;
      vid_rmask:=pss(screen.p)^.format^.rmask;
      vid_gmask:=pss(screen.p)^.format^.gmask;
      vid_bmask:=pss(screen.p)^.format^.bmask;
      vid_amask:=pss(screen.p)^.format^.amask;
    end;
    sdlcursor:=sdl_createcursor(@mousedata,@mousemask,16,16,0,0);
    mkscantab;
    if assigned(aginitcallback) then aginitcallback;
    if (vid_flags and 1)=0 then gclrscr(screen,0);
    result:=true;
  end else result:=false;
end;

procedure sdlAGDone;
begin
  sdl_freecursor(sdlcursor);
  donetimer;
  sdl_quitsubsystem(sdl_init_video or sdl_init_timer);
end;

procedure sdlUpdate(x1,y1,x2,y2:integer);
begin
  if vid_dblbuf then sdl_flip(screen.p) else begin
    if (x1=0) and (y1=0) and (x2=0) and (y2=0) then begin
      x2:=screen.w-1;
      y2:=screen.h-1;
    end;
    sdl_updaterect(screen.p,x1,y1,x2-x1+1,y2-y1+1);
  end;
end;

procedure sdl_SetPal(var srf:tsurface;var pal:vgapalette);
var
  p:array [0..255] of sdl_color;
  i:integer;
begin
  for i:=0 to 255 do begin
    p[i].r:=pal[i].r*4;
    p[i].g:=pal[i].g*4;
    p[i].b:=pal[i].b*4;
    p[i].unused:=0;
  end;
  sdl_setcolors(srf.p,@p,0,256);
end;

procedure sdlSetPal(var pal:vgapalette);
begin
  _setpal(screen,pal);
  move(pal,screenpal,768);
end;

procedure sdlSetColor(color:byte;r,g,b:byte);
var
  p:sdl_color;
begin
  screenpal[color].r:=r;
  screenpal[color].g:=g;
  screenpal[color].b:=b;
  p.r:=r*4;
  p.g:=g*4;
  p.b:=b*4;
  p.unused:=0;
  sdl_setcolors(screen.p,@p,color,1);
end;

function sdlMkSurface(var srf:tsurface;w,h:integer;hw,t:boolean;trans:longint):boolean;
var
  flags:integer;
begin
  result:=true;
  if hw then flags:=sdl_hwsurface else flags:=sdl_swsurface;
  srf.p:=sdl_creatergbsurface(flags,w,h,vid_bpp,0,0,0,0);
  if assigned(srf.p) then begin
    srf.w:=w;
    srf.h:=h;
    srf.hw:=hw;
    srf.transp:=t;
    srf.trans:=trans;
    if vid_bpp=8 then _setpal(srf,screenpal);
    if t then sdl_setcolorkey(srf.p,sdl_srccolorkey,trans);
    srf.mustlock:=(pss(srf.p)^.offset<>0) or ((pss(srf.p)^.flags and
      (SDL_HWSURFACE or SDL_ASYNCBLIT or SDL_RLEACCEL))<>0);
    gclrscr(srf,0);
  end else result:=false;
end;

procedure sdlRmSurface(var srf:tsurface);
begin
  sdl_freesurface(srf.p);
end;

function sdlLock(var srf:tsurface):pvidmem;
begin
  if srf.mustlock then begin
    while true do if sdl_locksurface(srf.p)>=0 then break;
  end;
  srf.pitch:=pss(srf.p)^.pitch;
  result:=pointer(pss(srf.p)^.pixels);
end;

procedure sdlUnlock(var srf:tsurface);
begin
  if srf.mustlock then sdl_unlocksurface(srf.p);
end;

procedure sdlblit(var src,dest:tsurface;x1,y1,x2,y2,dx,dy:integer);
var
  r1,r2:sdl_rect;
begin
  r1.x:=x1;r1.y:=y1;
  r1.w:=x2-x1+1;r1.h:=y2-y1+1;
  r2.x:=dx;r2.y:=dy;
  sdl_upperblit(src.p,@r1,dest.p,@r2);
end;

procedure sdlblit_force_notrans(var src,dest:tsurface;x1,y1,x2,y2,dx,dy:integer);
begin
  if src.transp then sdl_setcolorkey(src.p,0,0);
  blit(src,dest,x1,y1,x2,y2,dx,dy);
  if src.transp then sdl_setcolorkey(src.p,sdl_srccolorkey,src.trans);
end;

procedure sdlidle;
var
  event:sdl_event;
  i:integer;
begin
  if sdl_pollevent(@event)>0 then begin
    case event.typ of
      sdl_keydown:begin
        keydown[scantab[event.key.keysym.sym]]:=true;
        for i:=1 to 128+1 do
          if (symkeybuf[i].sym=0) or
            (symkeybuf[i].sym=event.key.keysym.sym) then break;
        if i=128+1 then begin
          i:=1;
          fillchar(symkeybuf,sizeof(symkeybuf),0);
        end;
        symkeybuf[i].sym:=event.key.keysym.sym;
        symkeybuf[i].modif:=event.key.keysym.modif;
      end;
      sdl_keyup:begin
        keydown[scantab[event.key.keysym.sym]]:=false;
        for i:=1 to 128 do if symkeybuf[i].sym=event.key.keysym.sym then begin
          symkeybuf[i].sym:=0;
          symkeybuf[i].modif:=0;
          break;
        end;
      end;
      sdl_eventquit:mustquit:=true;
      sdl_mousemotion:begin
        ag_mousex:=event.motion.x;
        ag_mousey:=event.motion.y;
      end;
      sdl_mousebuttondown:ag_mouseb:=ag_mouseb or (1 shl (event.button.button-1));
      sdl_mousebuttonup:ag_mouseb:=ag_mouseb and not (1 shl (event.button.button-1));
      sdl_eventactive:begin
        if (event.active.state and sdl_appactive)<>0 then begin
          isactive:=(event.active.gain=1);
        end;
      end;
    end;
  end;
end;

procedure sdlIdleN(n:integer);
var
  i:integer;
begin
  for i:=1 to n do idle; //stupid
end;

function getkey(sym,modif:integer):char;
var
  numon,capson,alton,shifton,ctrlon:boolean;
begin
  rk_schar:=false;
  numon:=(modif and kmod_num)<>0;
  capson:=(modif and kmod_caps)<>0;
  alton:=((modif and kmod_lalt)<>0) or ((modif and kmod_ralt)<>0);
  shifton:=((modif and kmod_lshift)<>0) or ((modif and kmod_rshift)<>0);
  ctrlon:=((modif and kmod_lctrl)<>0) or ((modif and kmod_rctrl)<>0);
  if (capson) and (shifton) then capson:=false else
    if (not capson) and (shifton) then capson:=true;
  result:=#0;
  if (sym in [sdlk_a..sdlk_z]) and (ctrlon) then result:=chr(sym-96);
  case sym of
    sdlk_a:if alton then result:=#30;
    sdlk_s:if alton then result:=#31;
    sdlk_d:if alton then result:=#32;
    sdlk_f:if alton then result:=#33;
    sdlk_g:if alton then result:=#34;
    sdlk_h:if alton then result:=#35;
    sdlk_j:if alton then result:=#36;
    sdlk_k:if alton then result:=#37;
    sdlk_l:if alton then result:=#38;
    sdlk_z:if alton then result:=#44;
    sdlk_x:if alton then result:=#45;
    sdlk_c:if alton then result:=#46;
    sdlk_v:if alton then result:=#47;
    sdlk_b:if alton then result:=#48;
    sdlk_n:if alton then result:=#49;
    sdlk_m:if alton then result:=#50;
    sdlk_q:if alton then result:=#16;
    sdlk_w:if alton then result:=#17;
    sdlk_e:if alton then result:=#18;
    sdlk_r:if alton then result:=#19;
    sdlk_t:if alton then result:=#20;
    sdlk_y:if alton then result:=#21;
    sdlk_u:if alton then result:=#22;
    sdlk_i:if alton then result:=#23;
    sdlk_o:if alton then result:=#24;
    sdlk_p:if alton then result:=#25;
    sdlk_1:if alton then result:=#120;
    sdlk_2:if alton then result:=#121;
    sdlk_3:if alton then result:=#122;
    sdlk_4:if alton then result:=#123;
    sdlk_5:if alton then result:=#124;
    sdlk_6:if alton then result:=#125;
    sdlk_7:if alton then result:=#126;
    sdlk_8:if alton then result:=#127;
    sdlk_9:if alton then result:=#128;
    sdlk_0:if alton then result:=#129;
    sdlk_f1:if alton then result:=#104;
    sdlk_f2:if alton then result:=#105;
    sdlk_f3:if alton then result:=#106;
    sdlk_f4:if alton then result:=#107;
    sdlk_f5:if alton then result:=#108;
    sdlk_f6:if alton then result:=#109;
    sdlk_f7:if alton then result:=#110;
    sdlk_f8:if alton then result:=#111;
    sdlk_f9:if alton then result:=#112;
    sdlk_f10:if alton then result:=#113;
  end;
  if result<>#0 then rk_schar:=true;
  if result=#0 then case sym of
    sdlk_escape:result:=#27;
    sdlk_1:if shifton then result:='!' else result:='1';
    sdlk_2:if shifton then result:='@' else result:='2';
    sdlk_3:if shifton then result:='#' else result:='3';
    sdlk_4:if shifton then result:='$' else result:='4';
    sdlk_5:if shifton then result:='%' else result:='5';
    sdlk_6:if shifton then result:='^' else result:='6';
    sdlk_7:if shifton then result:='&' else result:='7';
    sdlk_8:if shifton then result:='*' else result:='8';
    sdlk_9:if shifton then result:='(' else result:='9';
    sdlk_0:if shifton then result:=')' else result:='0';
    sdlk_minus:if shifton then result:='_' else result:='-';
    sdlk_equals:if shifton then result:='+' else result:='=';
    sdlk_backspace:result:=#8;
    sdlk_tab:result:=#9;
    sdlk_q:if capson then result:='Q' else result:='q';
    sdlk_w:if capson then result:='W' else result:='w';
    sdlk_e:if capson then result:='E' else result:='e';
    sdlk_r:if capson then result:='R' else result:='r';
    sdlk_t:if capson then result:='T' else result:='t';
    sdlk_y:if capson then result:='Y' else result:='y';
    sdlk_u:if capson then result:='U' else result:='u';
    sdlk_i:if capson then result:='I' else result:='i';
    sdlk_o:if capson then result:='O' else result:='o';
    sdlk_p:if capson then result:='P' else result:='p';
    sdlk_leftbracket:if shifton then result:='{' else result:='[';
    sdlk_rightbracket:if shifton then result:='}' else result:=']';
    sdlk_return,sdlk_kp_enter:result:=#13;
    sdlk_a:if capson then result:='A' else result:='a';
    sdlk_s:if capson then result:='S' else result:='s';
    sdlk_d:if capson then result:='D' else result:='d';
    sdlk_f:if capson then result:='F' else result:='f';
    sdlk_g:if capson then result:='G' else result:='g';
    sdlk_h:if capson then result:='H' else result:='h';
    sdlk_j:if capson then result:='J' else result:='j';
    sdlk_k:if capson then result:='K' else result:='k';
    sdlk_l:if capson then result:='L' else result:='l';
    sdlk_semicolon:if shifton then result:=':' else result:=';';
    sdlk_quote:if shifton then result:='"' else result:='''';
    sdlk_backquote:if shifton then result:='~' else result:='`';
    sdlk_backslash:if shifton then result:='|' else result:='\';
    sdlk_z:if capson then result:='Z' else result:='z';
    sdlk_x:if capson then result:='X' else result:='x';
    sdlk_c:if capson then result:='C' else result:='c';
    sdlk_v:if capson then result:='V' else result:='v';
    sdlk_b:if capson then result:='B' else result:='b';
    sdlk_n:if capson then result:='N' else result:='n';
    sdlk_m:if capson then result:='M' else result:='m';
    sdlk_comma:if shifton then result:='<' else result:=',';
    sdlk_period:if shifton then result:='>' else result:='.';
    sdlk_slash:if shifton then result:='?' else result:='/';
    sdlk_kp_multiply:result:='*';
    sdlk_space:result:=#32;
    sdlk_kp_minus:result:='-';
    sdlk_kp_plus:result:='+';
    sdlk_kp_divide:result:='/';
    sdlk_kp7:if numon then result:='7' else begin
      rk_schar:=true;
      result:=#71;
    end;
    sdlk_kp8:if numon then result:='8' else begin
      rk_schar:=true;
      result:=#72;
    end;
    sdlk_kp9:if numon then result:='9' else begin
      rk_schar:=true;
      result:=#73;
    end;
    sdlk_kp4:if numon then result:='4' else begin
      rk_schar:=true;
      result:=#75;
    end;
    sdlk_kp5:if numon then result:='5' else begin
      rk_schar:=true;
      result:=#0;
    end;
    sdlk_kp6:if numon then result:='6' else begin
      rk_schar:=true;
      result:=#77;
    end;
    sdlk_kp1:if numon then result:='1' else begin
      rk_schar:=true;
      result:=#79;
    end;
    sdlk_kp2:if numon then result:='2' else begin
      rk_schar:=true;
      result:=#80;
    end;
    sdlk_kp3:if numon then result:='3' else begin
      rk_schar:=true;
      result:=#81;
    end;
    sdlk_kp0:if numon then result:='0' else begin
      rk_schar:=true;
      result:=#82;
    end;
    sdlk_kp_period:if numon then result:='.' else begin
      rk_schar:=true;
      result:=#83;
    end;
    else begin
      rk_schar:=true;
      case sym of
        sdlk_f1:if alton then result:=#104 else result:=#59;
        sdlk_f2:if alton then result:=#105 else result:=#60;
        sdlk_f3:if alton then result:=#106 else result:=#61;
        sdlk_f4:if alton then result:=#107 else result:=#62;
        sdlk_f5:if alton then result:=#108 else result:=#63;
        sdlk_f6:if alton then result:=#109 else result:=#64;
        sdlk_f7:if alton then result:=#110 else result:=#65;
        sdlk_f8:if alton then result:=#111 else result:=#66;
        sdlk_f9:if alton then result:=#112 else result:=#67;
        sdlk_f10:if alton then result:=#113 else result:=#68;
        sdlk_f11:result:=#87;
        sdlk_f12:result:=#88;
        sdlk_home:result:=#71;
        sdlk_up:result:=#72;
        sdlk_pageup:result:=#73;
        sdlk_left:result:=#75;
        sdlk_right:result:=#77;
        sdlk_end:result:=#79;
        sdlk_down:result:=#80;
        sdlk_pagedown:result:=#81;
        sdlk_insert:result:=#82;
        sdlk_delete:result:=#83;
      end;
    end;
  end;
end;

function sdlRKey:char;
var
  i:integer;
begin
  result:=#0;
  repeat
    idle;
    for i:=1 to 128 do if symkeybuf[i].sym<>0 then begin
      result:=getkey(symkeybuf[i].sym,symkeybuf[i].modif);
      if result<>#0 then break;
    end;
  until result<>#0;
  symkeybuf[i].sym:=0;
  symkeybuf[i].modif:=0;
end;

function sdlKeyPress:boolean;
var
  i:integer;
begin
  result:=false;
  for i:=1 to 128 do if symkeybuf[i].sym<>0 then begin
    if getkey(symkeybuf[i].sym,symkeybuf[i].modif)<>#0 then begin
      result:=true;
      break;
    end;
  end;
end;

function sdlGetShiftStates:byte;
var
  ks:integer;
begin
  ks:=SDL_GetModState;
  result:=0;
  if ((ks and kmod_rshift)<>0) or ((ks and kmod_lshift)<>0) then
    result:=SHIFT_SHIFT;
  if ((ks and kmod_rctrl)<>0) or ((ks and kmod_lctrl)<>0) then
    result:=result or SHIFT_CTRL;
  if ((ks and kmod_ralt)<>0) or ((ks and kmod_lalt)<>0) then
    result:=result or SHIFT_ALT;
  if (ks and kmod_caps)<>0 then result:=result or SHIFT_CAPS;
  if (ks and kmod_num)<>0 then result:=result or SHIFT_NUM;
end;

//timer.start

const
  TIMER_MAX_PROCS=16;

var
  tmr:array [1..timer_max_procs] of record
    id:sdl_timerid;
    proc:TTimerProc;
  end;

procedure InitTimer;
begin
//  sdl_initsubsystem(sdl_init_timer);
  fillchar(tmr,sizeof(tmr),0);
end;

procedure DoneTimer;
begin
//  sdl_quitsubsystem(sdl_init_timer);
end;

function sdlInstallInt(proc:TTimerProc;speed:integer):boolean;
var
  i:integer;
begin
  for i:=1 to TIMER_MAX_PROCS+1 do begin
    if i>TIMER_MAX_PROCS then break;
    if not assigned(tmr[i].proc) then break;
  end;
  result:=(i<=TIMER_MAX_PROCS);
  if result then begin
    tmr[i].id:=sdl_addtimer(speed,proc,nil);
    tmr[i].proc:=proc;
   end;
end;

procedure sdlRemoveInt(proc:TTimerProc);
var
  i:integer;
begin
  for i:=1 to TIMER_MAX_PROCS do
    if @tmr[i].proc=@proc then begin
      sdl_removetimer(tmr[i].id);
      tmr[i].id:=0;
      tmr[i].proc:=nil;
    end;
end;

function sdlGetTicks:longint;
begin
  result:=SDL_GetTicks div 55;
end;

//timer.end

//mouse.start

procedure sdlShowMouse;
begin
  if not ag_mousevisible then begin
    SDL_ShowCursor(1);
    ag_mousevisible:=true;
  end;
end;

procedure sdlHideMouse;
begin
  if ag_mousevisible then begin
    SDL_ShowCursor(0);
    ag_mousevisible:=false;
  end;
end;

procedure sdlSetMouseCursor(newdata,newmask:pointer);
begin
  if (newdata<>nil) and (newmask<>nil) then begin
    move(newdata^,sdlcursor^.data^,32);
    move(newmask^,sdlcursor^.mask^,32);
    SDL_SetCursor(sdlcursor);
  end else begin
    SDL_SetCursor(defcursor);
  end;
end;

//mouse.end

procedure sdlAGDelay(ms:integer);
begin
  SDL_Delay(ms);
end;

procedure sdlWaitRetrace;
begin
  SDL_Delay(1000 div 70);
end;

procedure register_ag_sdl;
begin
  _real_AGInit:=sdlAGInit;
  _real_AGDone:=sdlAGDone;
  Update:=sdlUpdate;
  _SetPal:=sdl_SetPal;
  SetPal:=sdlSetPal;
  SetColor:=sdlSetColor;
  MkSurface:=sdlMkSurface;
  RmSurface:=sdlRmSurface;
  Lock:=sdlLock;
  Unlock:=sdlUnlock;
  blit:=sdlblit;
  blit_force_notrans:=sdlblit_force_notrans;
  Idle:=sdlIdle;
  IdleN:=sdlIdleN;
  RKey:=sdlRKey;
  KeyPress:=sdlKeyPress;
  GetShiftStates:=sdlGetShiftStates;
  InstallInt:=sdlInstallInt;
  RemoveInt:=sdlRemoveInt;
  GetTicks:=sdlGetTicks;
  ShowMouse:=sdlShowMouse;
  HideMouse:=sdlHideMouse;
  SetMouseCursor:=sdlSetMouseCursor;
  AGDelay:=sdlAGDelay;
  WaitRetrace:=sdlWaitRetrace;
  {$ifdef linux}
  ag_platform_id:='alpgraph for Linux/SDL';
  {$else}
  ag_platform_id:='alpgraph for Win32/SDL';
  {$endif}
end;

{$ifndef linux}
function GetModuleHandleA(name:pchar):pointer;stdcall;external 'kernel32.dll';
{$endif}

var
  i:integer;

initialization
  if SDL_Init(0)<0 then begin
    ag_halt('ag_sdl: SDL_Init failed');
  end;
  {$ifndef linux}
  SDL_SetModuleHandle(GetModuleHandleA(nil));
  {$endif}
  register_ag_sdl;
  for i:=0 to 11 do vid_ogl[i]:=-1;

finalization
  SDL_Quit;

end.
