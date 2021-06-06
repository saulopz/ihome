{ low-level part of alpgraph (WDOSX) }
{ (C) 2001 Laszlo Agocs (alp@dwp42.org) }
{ Uses WDosPorts, WDosDpmi and WDosCallbacks from Immo's DWPL }
{ For IRQ manipulation we use PMIRQ.WDL by Michael Tippach }
{ VESA 1.X code was taken from VBE.PAS which comes with WDOSX }

unit ag_wdosx;

interface

uses alpgraph;

procedure register_ag_wdosx;

//never call these directly
procedure wdxblit8(var src,dest:tsurface;x1,y1,x2,y2,dx,dy:integer);
procedure wdxblit16(var src,dest:tsurface;x1,y1,x2,y2,dx,dy:integer);
procedure wdxblit32(var src,dest:tsurface;x1,y1,x2,y2,dx,dy:integer);
procedure _showmousecursor8_16_32(mx,my:integer);

implementation

uses WDosPorts,WDosDpmi,WDosCallbacks;

type
  pv=pvidmem;
  T_showmousecursor=procedure(mx,my:integer);

var
  dosseg,dossel:integer;
  regs:dpmirmregisters;
  lfb_addr:pvidmem; //pointer to video memory
  rkey_tmp:char=#0; //for internal use by RKey
  grmode:integer=3; //3=textmode, $13=320x200, other=vesamode
  scrpitch:integer; //length of one scanline
  mback:TSurface; //content of 'screen' under mouse cursor
  convscr:pvidmem; //32=>24bpp converted data
  _showmousecursor:T_showmousecursor=nil;
  iswinnt:boolean; //are we running under Windows NT/2000?

function pow(base,n:longint):longint;
begin
  result:=1;
  while n>0 do begin
    result:=result*base;
    dec(n);
  end;
end;

procedure die(s:string);
begin
  AGDone;
  writeln(s);
  halt;
end;

function GetEnvironmentVariable(name,buffer:pchar;size:longint):longint;stdcall;
  external 'kernel32.dll' name 'GetEnvironmentVariableA';

function GetIRQHandler(irq:integer):TProc;stdcall;external 'pmirq.dll';
procedure SetIRQHandler(irq:integer;proc:TProc);stdcall;external 'pmirq.dll';

procedure KeyboardHandler(key:byte);
begin
  if key<>$e0 then begin
    if key>127 then keydown[key and 127]:=false else keydown[key]:=true;
  end;
end;

function MapPhysReg(mapstart,mapsize:integer):pointer;register;
asm
  push ebx
  push esi
  push edi
  mov ebx,eax
  mov ebx,eax
  mov eax,800h
  shr ebx,16
  mov esi,edx
  shr esi,16
  mov edi,edx
  int 31h
  mov eax,0
  jc @end
  shl ebx,16
  mov bx,cx
  mov eax,ebx
@end:
  pop edi
  pop esi
  pop ebx
end;

//vesa.start

type
  PVBEPMI=^TVBEPMI;
  TVBEPMI=packed record
    SetWindowOffset:word;
    SetDispStartOffset:word;
    SetPrimaryPalette:word;
    PortMemArrayOffset:word;
    PmCode:array [word] of byte;
  end;

  TModeInfo=packed record
    ModeAttributes:word;
    WinAAttributes:byte;
    WinBAttributes:byte;
    WinGranularity:word;
    WinSize:word;
    WinASegment:word;
    WinBSegment:word;
    WinFuncPtr:pointer;
    BytesPerScanLine:word;
    SizeX:word;
    SizeY:word;
    CharSizeX:byte;
    CharSizeY:byte;
    NumberOfPlanes:byte;
    BitsPerPixel:byte;
    NumberOfBanks:byte;
    MemoryModel:byte;
    BankSize:byte;
    NumberOfImagePages:byte;
    Reserved1:byte;
    RedMaskSize:byte;
    RedFieldPosition:byte;
    GreenMaskSize:byte;
    GreenFieldPosition:byte;
    BlueMaskSize:byte;
    BlueFieldPosition:byte;
    RsvdMaskSize:byte;
    RsvdFieldPosition:byte;
    DirectColorInfo:byte;
    {VBE 2.0+}
    LfbPtr:longint;
    OffScreenMemOffset:pointer;
    OffScreenMemSize:word;
    Reserved2:array [0..205] of byte;
  end;

var
  modeinfo:TModeInfo;
  PmiBankSwitcher:pointer;
  V1_ScreenBuffer:pointer;
  V1_WindowSize:longint;
  V1_BlockSize:longint;
  V1_BankIncrement:longint;
  V1_CurrentBank:longint;
  V1_NumBlocks:longint;
  pmi:PVBEPMI;

procedure SetBank(bank:integer);assembler;register;
asm
  mov edx,eax
  cmp V1_CurrentBank,edx
  je @@done
  mov V1_CurrentBank,edx
  mov ecx,PmiBankSwitcher
{
  A well behaved implementation would not destroy esi and ebp as the VBE 2
  standard says that it must not.
}
  push edi
  push ebx
  mov eax,4F05h
  sub ebx,ebx
  test ecx,ecx
  je @@UseInt
  push offset @@Return
  jmp ecx
@@UseInt:
  int 10h
@@Return:
  pop ebx
  pop edi
@@done:
end;

procedure wdxWaitRetrace;
begin
  while (port[$3da] and 8)>0 do ;
  while (port[$3da] and 8)=0 do ;
end;

procedure V1_Flip(waitretrace:boolean);
var
  sPtr,dPtr:pointer;
  tSize,bi,i,sz:longint;
begin
  bi:=0;
  sPtr:=screen.p;
  sz:=screen.w*screen.h*((vid_realbpp+7) shr 3);
  if vid_realbpp=24 then begin
    _32_to_24(pointer(screen.p),pointer(convscr),screen.w,screen.h,screen.w*4,screen.w*3);
    sPtr:=convscr;
  end;
  if waitretrace then wdxWaitRetrace;
  for i:=0 to V1_NumBlocks-1 do begin
    dPtr:=V1_ScreenBuffer;
    SetBank(bi);
    inc(bi,V1_BankIncrement);
    if sz>V1_BlockSize then tSize:=V1_BlockSize else tSize:=sz;
    dec(sz,V1_BlockSize);
    asm
      cld
      mov ecx,tSize
      push edi
      push esi
      mov esi,sPtr
      mov edi,dPtr
      shr ecx,2
      rep movsd
      mov sPtr,esi
      pop esi
      pop edi
    end;
  end;
end;

//update.start

var
  upd_mx,upd_my,upd_mx2,upd_my2:integer;

procedure check_upd_m(mx,my:integer);
begin
  upd_mx:=mx;upd_my:=my;
  upd_mx2:=mx+15;
  if upd_mx2>=screen.w then upd_mx2:=screen.w-1;
  upd_my2:=my+15;
  if upd_my2>=screen.h then upd_my2:=screen.h-1;
end;

procedure V1_Update(x1,y1,x2,y2:integer); //currently ignores parameters
var
  m:boolean;
begin
  m:=ag_mousevisible;
  if m then begin
    check_upd_m(ag_mousex,ag_mousey);
    blit(screen,mback,upd_mx,upd_my,upd_mx2,upd_my2,0,0);
    _showmousecursor(upd_mx,upd_my);
  end;
  V1_Flip(vid_dblbuf);
  if m then blit(mback,screen,0,0,upd_mx2-upd_mx,upd_my2-upd_my,upd_mx,upd_my);
end;

procedure LFB_Update(x1,y1,x2,y2:integer);
var
  w,y,bypp:integer;
  m:boolean;
  p:pvidmem;
begin
  if ((x1=0) and (y1=0) and (x2=0) and (y2=0)) or (vid_dblbuf) then begin
    x2:=screen.w-1;
    y2:=screen.h-1;
  end;
  w:=x2-x1+1;
  m:=ag_mousevisible;
  if m then begin
    check_upd_m(ag_mousex,ag_mousey);
    blit(screen,mback,upd_mx,upd_my,upd_mx2,upd_my2,0,0);
    _showmousecursor(upd_mx,upd_my);
  end;
  p:=screen.p;
  bypp:=vid_bypp;
  if vid_realbpp=24 then begin
    _32_to_24(pointer(screen.p),pointer(convscr),screen.w,screen.h,screen.w*4,screen.w*3);
    p:=convscr;
    bypp:=3;
  end;
  if vid_dblbuf then wdxWaitRetrace;
  for y:=y1 to y2 do
    move(p^[bypp*(x1+y*screen.w)],lfb_addr^[bypp*(x1+y*screen.w)],w*bypp);
  if m then begin
    for y:=upd_my to upd_my2 do
      move(p^[bypp*(upd_mx+y*screen.w)],
        lfb_addr^[bypp*(upd_mx+y*screen.w)],bypp*(upd_mx2-upd_mx+1));
    blit(mback,screen,0,0,upd_mx2-upd_mx,upd_my2-upd_my,upd_mx,upd_my);
  end;
end;

//update.end

{
101h     -        640x480      256
103h     -        800x600      256
105h     -        1024x768     256
10Dh     -        320x200      32K   (1:5:5:5)
10Eh     -        320x200      64K   (5:6:5)
10Fh     -        320x200      16.8M (8:8:8)
110h     -        640x480      32K   (1:5:5:5)
111h     -        640x480      64K   (5:6:5)
112h     -        640x480      16.8M (8:8:8)
113h     -        800x600      32K   (1:5:5:5)
114h     -        800x600      64K   (5:6:5)
115h     -        800x600      16.8M (8:8:8)
116h     -        1024x768     32K   (1:5:5:5)
117h     -        1024x768     64K   (5:6:5)
118h     -        1024x768     16.8M (8:8:8)
}

procedure InitTimer;forward;
procedure DoneTimer;forward;
function InitMouse:boolean;forward;
procedure DoneMouse;forward;

function wdxAGInit(xs,ys,bpp:integer;caption:ansistring;full,dblbuf:boolean):boolean;
var
  id:array [1..4] of char;
  m,w,ver:word;
  tryvesa1:boolean;
begin
  if not(bpp in [8,16,32]) then begin
    result:=false;
    exit;
  end;
  result:=true;
  if (xs=320) and (ys=200) and (bpp=8) then begin
    asm
      mov ax,13h
      int 10h
    end;
    grmode:=$13;
    getmem(screen.p,xs*ys);
    screen.w:=xs;
    screen.h:=ys;
    scrpitch:=xs;
    screen.transp:=false;
    screen.trans:=0;
    vid_bpp:=8;vid_realbpp:=8;vid_bypp:=1;
    vid_dblbuf:=dblbuf;
    lfb_addr:=pointer($A0000);
    Update:=LFB_Update;
    blit:=wdxblit8;
    _showmousecursor:=_showmousecursor8_16_32;
    if assigned(aginitcallback) then aginitcallback;
    gclrscr(screen,0);
    vid_banked:=false;
  end else begin
    m:=0; //to avoid the stupid delphi hint
    case xs of
      320:if bpp=16 then m:=$10E else m:=$10F;
      640:if bpp=8 then m:=$101 else if bpp=16 then m:=$111 else m:=$112;
      800:if bpp=8 then m:=$103 else if bpp=16 then m:=$114 else m:=$115;
      1024:if bpp=8 then m:=$105 else if bpp=16 then m:=$117 else m:=$118;
      else result:=false;
    end;
    if result then begin
      regs.ss:=0;
      regs.sp:=0;
      regs.es:=dosseg;
      regs.edi:=0;
      regs.eax:=$4f00;
      dpmirealmodeint($10,regs);
      move(pointer(longint(dosseg) shl 4)^,id,4);
      ver:=memw[dosseg shl 4+4];
      if vid_banked then ver:=0; //force bankswitched modes
      tryvesa1:=false;
      if (regs.al=$4f) and (regs.ah=$00) and (ver>=$0200) then begin
        regs.es:=dosseg;
        regs.edi:=0;
        regs.eax:=$4f01;
        regs.ecx:=m;
        dpmirealmodeint($10,regs);
        if regs.ah=$00 then begin
          move(pointer(longint(dosseg) shl 4)^,modeinfo,256);
          if (modeinfo.modeattributes and $80)<>0 then begin
            vid_bpp:=bpp;
            vid_realbpp:=modeinfo.bitsperpixel;
            vid_bypp:=(bpp+7) shr 3;
            vid_rshift:=modeinfo.redfieldposition;
            vid_gshift:=modeinfo.greenfieldposition;
            vid_bshift:=modeinfo.bluefieldposition;
            vid_rmask:=(pow(2,modeinfo.redmasksize)-1) shl vid_rshift;
            vid_gmask:=(pow(2,modeinfo.greenmasksize)-1) shl vid_gshift;
            vid_bmask:=(pow(2,modeinfo.bluemasksize)-1) shl vid_bshift;
            lfb_addr:=mapphysreg(modeinfo.lfbptr,xs*ys*((vid_realbpp+7) shr 3));
            if lfb_addr<>nil then begin
              regs.ebx:=m or $4000;
              regs.eax:=$4f02;
              dpmirealmodeint($10,regs);
              if regs.ah=$00 then begin
                asm //Set scanline length
                  push ebx
                  mov ax,4f06h
                  xor bx,bx
                  mov ecx,xs
                  int 10h
                  mov w,bx
                  pop ebx
                end;
                getmem(screen.p,xs*ys*vid_bypp);
                screen.w:=xs;
                screen.h:=ys;
                scrpitch:=w*vid_bypp;
                screen.transp:=false;
                screen.trans:=0;
                vid_dblbuf:=dblbuf;
                Update:=LFB_Update;
                _showmousecursor:=_showmousecursor8_16_32;
                case bpp of
                  8:begin
                    blit:=wdxblit8;
                  end;
                  16:begin
                    blit:=wdxblit16;
                  end;
                  32:begin
                    blit:=wdxblit32;
                  end;
                end;
                if vid_realbpp=24 then getmem(convscr,xs*ys*3);
                if assigned(aginitcallback) then aginitcallback;
                gclrscr(screen,0);
                grmode:=m;
                vid_banked:=false;
              end else result:=false;
            end else tryvesa1:=true; //mapphysreg failed, maybe we are in NT
          end else tryvesa1:=true; //if no LFB try bankswitched
        end else result:=false;
      end else if (regs.al=$4f) and (regs.ah=$00) then tryvesa1:=true else result:=false;
      if tryvesa1 then begin //VESA 1.X
        if ver=0 then ver:=memw[dosseg shl 4+4];
        regs.es:=dosseg;
        regs.edi:=0;
        regs.eax:=$4f01;
        regs.ecx:=m;
        dpmirealmodeint($10,regs);
        if regs.ah=$00 then begin
          move(pointer(longint(dosseg) shl 4)^,modeinfo,256);
          vid_bpp:=bpp;
          vid_realbpp:=modeinfo.bitsperpixel;
          vid_bypp:=(bpp+7) shr 3;
          vid_rshift:=modeinfo.redfieldposition;
          vid_gshift:=modeinfo.greenfieldposition;
          vid_bshift:=modeinfo.bluefieldposition;
          vid_rmask:=(pow(2,modeinfo.redmasksize)-1) shl vid_rshift;
          vid_gmask:=(pow(2,modeinfo.greenmasksize)-1) shl vid_gshift;
          vid_bmask:=(pow(2,modeinfo.bluemasksize)-1) shl vid_bshift;
          V1_ScreenBuffer:=pointer(longint(modeinfo.WinASegment) shl 4);
          V1_WindowSize:=longint(modeinfo.WinSize) shl 10;
          V1_BlockSize:=V1_WindowSize-(V1_WindowSize mod (longint(modeinfo.WinGranularity) shl 10));
          V1_BankIncrement:=V1_BlockSize div (longint(modeinfo.WinGranularity) shl 10);
          V1_CurrentBank:=-1;
          pmi:=nil;
          PmiBankSwitcher:=nil;
          if ver>=$0200 then begin
            regs.ax:=$4f0a;
            regs.bl:=0;
            dpmirealmodeint($10,regs);
            if regs.ax=$4f then begin
              pmi:=pointer((longint(regs.es) shl 4)+regs.di);
              PmiBankSwitcher:=@(pmi^.PmCode[pmi^.SetWindowOffset-8]);
            end;
          end;
          regs.ebx:=m;
          regs.eax:=$4f02;
          dpmirealmodeint($10,regs);
          if regs.ah=$00 then begin
            SetBank(0);
            V1_NumBlocks:=xs*ys*((vid_realbpp+7) shr 3) div V1_BlockSize;
            if ((xs*ys*(vid_realbpp+7 shr 3)) mod V1_BlockSize)>0 then inc(V1_NumBlocks);
            getmem(screen.p,xs*ys*vid_bypp);
            screen.w:=xs;
            screen.h:=ys;
            scrpitch:=w*vid_bypp;
            screen.transp:=false;
            screen.trans:=0;
            vid_dblbuf:=dblbuf;
            grmode:=m;
            vid_banked:=true;
            Update:=V1_Update;
            _showmousecursor:=_showmousecursor8_16_32;
            case bpp of
              8:begin
                blit:=wdxblit8;
              end;
              16:begin
                blit:=wdxblit16;
              end;
              32:begin
                blit:=wdxblit32;
              end;
            end;
            if vid_realbpp=24 then getmem(convscr,xs*ys*3);
            if assigned(aginitcallback) then aginitcallback;
            gclrscr(screen,0);
          end else result:=false;
        end else result:=false;
      end;
    end;
  end;
  if result then begin
    if vid_bpp=8 then begin
      port[$3c7]:=0;
      for w:=0 to 255 do begin
        screenpal[w].r:=port[$3c9];
        screenpal[w].g:=port[$3c9];
        screenpal[w].b:=port[$3c9];
      end;
    end;
    ag_mouseok:=InitMouse;
    AddKeyboardCallback(KeyboardHandler);
    if not IsImmoPresent then InitTimer;
  end;
end;

procedure wdxAGDone;
begin
  DoneMouse;
  if not IsImmoPresent then DoneTimer;
  RemoveKeyboardCallback(KeyboardHandler);
  if vid_realbpp=24 then freemem(convscr);
  freemem(screen.p);
  asm
    mov ax,3
    int 10h
  end;
  grmode:=3;
end;

//vesa.end

var
  mousepixels8:array [0..1] of byte;

procedure upd_mousepixels8;
begin
  mousepixels8[0]:=getclosestcolor(screenpal,63,63,63);
  mousepixels8[1]:=getclosestcolor(screenpal,0,0,0);
end;

procedure wdx_SetPal(var srf:tsurface;var pal:vgapalette); //not needed
begin
end;

procedure wdxSetPal(var pal:vgapalette);
var
  i:integer;
begin
  port[$3c8]:=0;
  for i:=0 to 255 do begin
    port[$3c9]:=pal[i].r;
    port[$3c9]:=pal[i].g;
    port[$3c9]:=pal[i].b;  
  end;
  move(pal,screenpal,768);
  upd_mousepixels8;
end;

procedure wdxSetColor(color:byte;r,g,b:byte);
begin
  screenpal[color].r:=r;
  screenpal[color].g:=g;
  screenpal[color].b:=b;
  port[$3c8]:=color;
  port[$3c9]:=r;
  port[$3c9]:=g;
  port[$3c9]:=b;
  if (color=mousepixels8[0]) or (color=mousepixels8[1]) then upd_mousepixels8;
end;

function wdxMkSurface(var srf:tsurface;w,h:integer;hw,t:boolean;trans:longint):boolean;
begin
  result:=true;
  try
    getmem(srf.p,w*h*vid_bypp);
  except
    srf.p:=nil;
  end;
  if assigned(srf.p) then begin
    srf.w:=w;
    srf.h:=h;
    srf.transp:=t;
    srf.trans:=trans;
    srf.pitch:=w*vid_bypp;
    srf.mustlock:=false;
    fillchar(srf.p^,w*h*vid_bypp,0);
  end else result:=false;
end;

procedure wdxRmSurface(var srf:tsurface);
begin
  freemem(srf.p);
  srf.p:=nil;
end;

function wdxLock(var srf:tsurface):pvidmem;
begin
  result:=srf.p;
end;

procedure wdxUnlock(var srf:tsurface);
begin
end;

procedure wdxblit8(var src,dest:tsurface;x1,y1,x2,y2,dx,dy:integer);
var
  x,y:integer;
  c:byte;
begin //Lock isn't needed in dos version
  if src.transp then begin
    for y:=y1 to y2 do
      for x:=x1 to x2 do begin
        c:=pv(src.p)^[x+y*src.w];
        if c<>src.trans then pv(dest.p)^[dx+(x-x1)+((dy+(y-y1))*dest.w)]:=c;
      end;
  end else begin
    for y:=y1 to y2 do
      move(pv(src.p)^[x1+y*src.w],pv(dest.p)^[dx+(dy+y-y1)*dest.w],x2-x1+1);
  end;
end;

procedure wdxblit16(var src,dest:tsurface;x1,y1,x2,y2,dx,dy:integer);
var
  x,y:integer;
  c:longint;
begin //Lock isn't needed in dos version
  if src.transp then begin
    for y:=y1 to y2 do
      for x:=x1 to x2 do begin
        c:=pvidmemw(src.p)^[x+y*src.w];
        if c<>src.trans then
          pvidmemw(dest.p)^[dx+(x-x1)+((dy+(y-y1))*dest.w)]:=c;
      end;
  end else begin
    for y:=y1 to y2 do
      move(pv(src.p)^[x1*vid_bypp+y*src.w*vid_bypp],
        pv(dest.p)^[dx*vid_bypp+(dy+y-y1)*dest.w*vid_bypp],(x2-x1+1)*vid_bypp);
  end;
end;

procedure wdxblit32(var src,dest:tsurface;x1,y1,x2,y2,dx,dy:integer);
var
  x,y:integer;
  c:longint;
begin //Lock isn't needed in dos version
  if src.transp then begin
    for y:=y1 to y2 do
      for x:=x1 to x2 do begin
        c:=pvidmeml(src.p)^[x+y*src.w];
        if c<>src.trans then
          pvidmeml(dest.p)^[dx+(x-x1)+((dy+(y-y1))*dest.w)]:=c;
      end;
  end else begin
    for y:=y1 to y2 do
      move(pv(src.p)^[x1*vid_bypp+y*src.w*vid_bypp],
        pv(dest.p)^[dx*vid_bypp+(dy+y-y1)*dest.w*vid_bypp],(x2-x1+1)*vid_bypp);
  end;
end;

procedure wdxblit_force_notrans(var src,dest:tsurface;x1,y1,x2,y2,dx,dy:integer);
var
  oldtransp:boolean;
begin
  oldtransp:=src.transp;
  src.transp:=false;
  blit(src,dest,x1,y1,x2,y2,dx,dy);
  src.transp:=oldtransp;
end;

function crt_keypressed:boolean;
begin
  asm
    mov ah,1
    mov result,false
    int 16h
    jz @1
    mov result,true
  @1:
  end;
end;

function crt_readkey:char;
begin
  if rkey_tmp<>#0 then begin
    result:=rkey_tmp;
    rkey_tmp:=#0;
  end else begin
    asm
      xor ax,ax
      int 16h
      mov result,al
      cmp al,1
      sbb al,al
      and al,ah
      mov rkey_tmp,al
    end;
  end;
end;

//mousecursor.start

const
  default_cdata:array [0..31] of byte=(
    $00,$00,
    $40,$00,
    $60,$00,
    $70,$00,
    $78,$00,
    $7C,$00,
    $7E,$00,
    $7F,$00,
    $7F,$80,
    $7C,$00,
    $6C,$00,
    $46,$00,
    $06,$00,
    $03,$00,
    $03,$00,
    $00,$00
  );

  default_cmask:array [0..31] of byte=(
    $40,$00,
    $E0,$00,
    $F0,$00,
    $F8,$00,
    $FC,$00,
    $FE,$00,
    $FF,$00,
    $FF,$80,
    $FF,$C0,
    $FF,$80,
    $FE,$00,
    $EF,$00,
    $4F,$00,
    $07,$80,
    $07,$80,
    $03,$00
  );

var
  _omousex,_omousey:integer; //used by Idle
  mousedata,mousemask:array [0..31] of byte;

procedure _showmousecursor8_16_32(mx,my:integer);
type
  pbyte=^byte;
const
  mousepixels:array [0..1] of longint=($FFFFFF,$000000);
var
  x,minx,maxx,h,dstbpp,dstskip:integer;
  data,mask,dst:pbyte;
  datab,maskb:byte;
begin
  if mx>=screen.w then exit;
  if my>=screen.h then exit;
  datab:=0;maskb:=0;
  data:=@mousedata;
  mask:=@mousemask;
  dstbpp:=vid_bypp;
  dst:=pointer(Lock(screen));
  inc(dst,mx*vid_bypp+my*screen.pitch);
  dstskip:=screen.pitch-16*dstbpp;
  minx:=mx;
  maxx:=mx+16;
  if maxx>=screen.w then maxx:=screen.w-1;
  if vid_bypp=1 then begin
    for h:=0 to 15 do begin
      if my+h>=screen.h then break;
      for x:=0 to 15 do begin
        if x mod 8=0 then begin
          maskb:=mask^;
          datab:=data^;
          inc(mask);
          inc(data);
        end;
        if (x+mx>=minx) and (x+mx<maxx) then begin
          if (maskb and $80)<>0 then dst^:=mousepixels8[datab shr 7];
        end;
        maskb:=maskb shl 1;
        datab:=datab shl 1;
        inc(dst);
      end;
      inc(dst,dstskip);
    end;
  end else begin
    for h:=0 to 15 do begin
      if my+h>=screen.h then break;
      for x:=0 to 15 do begin
        if x mod 8=0 then begin
          maskb:=mask^;
          datab:=data^;
          inc(mask);
          inc(data);
        end;
        if (x+mx>=minx) and (x+mx<maxx) then begin
          if (maskb and $80)<>0 then move(mousepixels[datab shr 7],dst^,dstbpp);
        end;
        maskb:=maskb shl 1;
        datab:=datab shl 1;
        inc(dst,dstbpp);
      end;
      inc(dst,dstskip);
    end;
  end;
  UnLock(screen);
end;

//mousecursor.end

var
  in_rkey:boolean=false;

procedure wdxidle;
var
  mx,my:integer;
begin
  if not in_rkey then while crt_keypressed do crt_readkey;
  if ag_mousevisible then begin
    mx:=ag_mousex;my:=ag_mousey;
    if (_omousex<>mx) or (_omousey<>my) then begin
      check_upd_m(_omousex,_omousey);
      update(upd_mx,upd_my,upd_mx2,upd_my2);
      _omousex:=mx;
      _omousey:=my;
    end;
  end;
end;

procedure wdxIdleN(n:integer);
begin
  idle;
end;

function wdxRKey:char;
begin
  rk_schar:=false;
  result:=#255;
  in_rkey:=true;
  repeat
    idle;
    if crt_keypressed then result:=crt_readkey;
  until result<>#255;
  in_rkey:=false;
  if result=#0 then begin
    result:=crt_readkey;
    rk_schar:=true;
  end;
end;

function wdxKeyPress:boolean;
begin
  result:=crt_keypressed;
end;

function wdxGetShiftStates:byte;
var
  ks:byte;
begin
  ks:=mem[$417];
  result:=0;
  if ((ks and 1)<>0) or ((ks and 2)<>0) then result:=SHIFT_SHIFT;
  if (ks and 4)<>0 then result:=result or SHIFT_CTRL;
  if (ks and 8)<>0 then result:=result or SHIFT_ALT;
  if (ks and $40)<>0 then result:=result or SHIFT_CAPS;
  if (ks and $20)<>0 then result:=result or SHIFT_NUM;
end;

//timer.start

procedure _SetTimer(num:word);assembler;register;
asm
  mov dx,ax
  mov al,36h
  out 43h,al
  mov ax,dx
  out 40h,al
  mov al,ah
  out 40h,al
end;

const
  TIMER_MAX_PROCS=16;

var
  tmr,tmr2:array [1..TIMER_MAX_PROCS] of record
    proc:TTimerProc;
    speed:integer;
  end;
  calloldcnt:cardinal;
  oldtimerint:TProc;

procedure timerint;
var
  i:integer;
begin
  for i:=1 to TIMER_MAX_PROCS do
    if assigned(tmr[i].proc) then begin
      if tmr[i].speed<=0 then begin
        tmr[i].proc(tmr2[i].speed,nil);
        tmr[i].speed:=tmr2[i].speed;
      end else dec(tmr[i].speed,5);
    end;
  if calloldcnt=11 then begin
    oldtimerint;
    calloldcnt:=0;
  end else begin
    inc(calloldcnt);
    port[$20]:=$20;
  end;
end;

procedure InitTimer;
begin
  fillchar(tmr,sizeof(tmr),0);
  calloldcnt:=0;
  oldtimerint:=getirqhandler(0);
  setirqhandler(0,timerint);
  _settimer(1193*5); //call timerint every 5 ms
end;

procedure DoneTimer;
begin
  _settimer(0);
  setirqhandler(0,oldtimerint);
end;

function wdxInstallInt(proc:TTimerProc;speed:integer):boolean;
var
  i:integer;
begin
  if IsImmoPresent then die('alpgraph.installint: timer was not initialized');
  for i:=1 to TIMER_MAX_PROCS+1 do begin
    if i>TIMER_MAX_PROCS then break;
    if not assigned(tmr[i].proc) then break;
  end;
  result:=(i<=TIMER_MAX_PROCS);
  if result then begin
    tmr[i].speed:=speed;
    tmr[i].proc:=proc;
    tmr2[i].speed:=speed;
    tmr2[i].proc:=proc;
  end;
end;

procedure wdxRemoveInt(proc:TTimerProc);
var
  i:integer;
begin
  for i:=1 to TIMER_MAX_PROCS+1 do begin
    if i>TIMER_MAX_PROCS then break;
    if @tmr[i].proc=@proc then break;
  end;
  if i<=TIMER_MAX_PROCS then begin
    tmr[i].proc:=nil;
    tmr[i].speed:=0;
    tmr2[i].proc:=nil;
    tmr2[i].speed:=0;
  end;
end;

function wdxGetTicks:longint;
begin
  result:=plongint($46c)^;
end;

//timer.end

//mouse.start

var
  mr:dpmirmregisters;
  mxshift,myshift:integer;

procedure MouseXY(x,y:word);
begin
  mr.ax:=4;
  mr.cx:=x shl mxshift;
  mr.dx:=y shl myshift;
  dpmirealmodeint($33,mr);
  ag_mousex:=x;
  ag_mousey:=y;
end;

procedure MouseArea(x1,y1,x2,y2:word);
begin
  mr.ax:=7;
  mr.cx:=x1 shl mxshift;
  mr.dx:=x2 shl mxshift;
  dpmirealmodeint($33,mr);
  mr.ax:=8;
  mr.cx:=y1 shl myshift;
  mr.dx:=y2 shl myshift;
  dpmirealmodeint($33,mr);
end;

procedure MouseHandler(mx,my,mb,mc:integer);pascal;
begin
  ag_mousex:=mx shr mxshift;
  ag_mousey:=my shr myshift;
  if (mb and 1)<>0 then ag_mouseb:=ag_mouseb or mbut_left else
    ag_mouseb:=ag_mouseb and not mbut_left;
  if (mb and 2)<>0 then ag_mouseb:=ag_mouseb or mbut_right else
    ag_mouseb:=ag_mouseb and not mbut_right;
  if (mb and 4)<>0 then ag_mouseb:=ag_mouseb or mbut_mid else
    ag_mouseb:=ag_mouseb and not mbut_mid;
end;

function InitMouse:boolean;
begin
  result:=MouseAvailable;
  if result then begin
    case grmode of
      3:begin //this can't be possible
        mxshift:=3;
        myshift:=3;
      end;
      $13:begin
        mxshift:=1;
        myshift:=0;
      end;
      else begin
        mxshift:=0;
        myshift:=0;
      end;
    end;
    mousearea(0,0,screen.w-1,screen.h-1);
    mousexy(0,0);
    ag_mouseb:=0;
    mousepixels8[0]:=getclosestcolor(screenpal,63,63,63);
    mousepixels8[1]:=getclosestcolor(screenpal,0,0,0);
    move(default_cdata,mousedata,32);
    move(default_cmask,mousemask,32);
    mksurface(mback,16,16,false,false,0);
    AddMouseCallback(MouseHandler,$7F);
  end;
end;

procedure DoneMouse;
begin
  RemoveMouseCallback(MouseHandler);
  hidemouse;
  rmsurface(mback);
end;

procedure wdxShowMouse;
begin
  if not ag_mousevisible then begin
    ag_mousevisible:=true;
    update(0,0,0,0);
  end;
end;

procedure wdxHideMouse;
begin
  if ag_mousevisible then begin
    ag_mousevisible:=false;
    update(0,0,0,0);
  end;
end;

procedure wdxSetMouseCursor(newdata,newmask:pointer);
var
  m:boolean;
begin
  m:=ag_mousevisible;
  if m then hidemouse;
  if (newdata<>nil) and (newmask<>nil) then begin
    move(newdata^,mousedata,32);
    move(newmask^,mousemask,32);
  end else begin
    move(default_cdata,mousedata,32);
    move(default_cmask,mousemask,32);
  end;
  if m then showmouse;
end;

//mouse.end

var
  delaycnt:longint;

function delaytmr(i:longint;param:pointer):longint;cdecl;
begin
  inc(delaycnt,5);
  result:=i;
end;

procedure wdxAGDelay(ms:integer);
begin
  if not iswinnt then asm //taken from Michael Tippach's CRT unit
    sub ecx,ecx
    mov edx,ms
    shl edx,10
    shld ecx,edx,16
    mov ah,86h
    int 15h
  end else begin //this is anything but accurate ;-)
    installint(delaytmr,5);
    delaycnt:=0;
    repeat
    until delaycnt>=ms;
    removeint(delaytmr);
  end;
end;

procedure register_ag_wdosx;
begin
  _real_AGInit:=wdxAGInit;
  _real_AGDone:=wdxAGDone;
  Update:=LFB_Update; //will be changed by AGInit!
  _SetPal:=wdx_SetPal;
  SetPal:=wdxSetPal;
  SetColor:=wdxSetColor;
  MkSurface:=wdxMkSurface;
  RmSurface:=wdxRmSurface;
  Lock:=wdxLock;
  Unlock:=wdxUnlock;
  blit:=wdxblit8; //will be changed by AGInit!
  blit_force_notrans:=wdxblit_force_notrans;
  Idle:=wdxIdle;
  IdleN:=wdxIdleN;
  RKey:=wdxRKey;
  KeyPress:=wdxKeyPress;
  GetShiftStates:=wdxGetShiftStates;
  InstallInt:=wdxInstallInt;
  RemoveInt:=wdxRemoveInt;
  GetTicks:=wdxGetTicks;
  ShowMouse:=wdxShowMouse;
  HideMouse:=wdxHideMouse;
  SetMouseCursor:=wdxSetMouseCursor;
  AGDelay:=wdxAGDelay;
  WaitRetrace:=wdxWaitRetrace;
  ag_platform_id:='alpgraph for WDOSX';
end;

var
  s:shortstring;
  buf:array [0..511] of char;
  i:integer;

initialization
  dpmiallocdosmem(32,dosseg,dossel); //512 bytes
  register_ag_wdosx;
  iswinnt:=false;
  if GetEnvironmentVariable('OS',buf,512)>0 then begin
    i:=0;
    while buf[i]>#0 do begin
      s[i+1]:=buf[i];
      inc(i);
    end;
    s[0]:=chr(i);
    iswinnt:=(s='Windows_NT');
  end;

finalization
  dpmifreedosmem(dossel);

end.
