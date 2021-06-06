unit sdl;
{ Delphi conversion of SDL 1.1.8 header files }
{ A lot of things are missing! (sound functions, etc.) }
{ Made by alp@dwp42.org }

interface

const
  SDL_INIT_TIMER=$00000001;
  SDL_INIT_AUDIO=$00000010;
  SDL_INIT_VIDEO=$00000020;
  SDL_INIT_CDROM=$00000100;
  SDL_INIT_JOYSTICK=$00000200;
  SDL_INIT_NOPARACHUTE=$00100000; //Don't catch fatal signals
  SDL_INIT_EVENTTHREAD=$01000000; //Not supported on all OS's
  SDL_INIT_EVERYTHING=$0000FFFF;

  SDL_APPMOUSEFOCUS=$01;
  SDL_APPINPUTFOCUS=$02;
  SDL_APPACTIVE=$04;

  SDL_NOEVENT=0; //Unused (do not remove)
  SDL_EVENTACTIVE=1; //Application loses/gains visibility [C: SDL_ACTIVEEVENT]
  SDL_KEYDOWN=2; //Keys pressed
  SDL_KEYUP=3; //Keys released
  SDL_MOUSEMOTION=4; //Mouse moved
  SDL_MOUSEBUTTONDOWN=5; //Mouse button pressed
  SDL_MOUSEBUTTONUP=6; //Mouse button released
  SDL_JOYAXISMOTION=7; //Joystick axis motion
  SDL_JOYBALLMOTION=8; //Joystick trackball motion
  SDL_JOYHATMOTION=9; //Joystick hat position change
  SDL_JOYBUTTONDOWN=10; //Joystick button pressed
  SDL_JOYBUTTONUP=11; //Joystick button released
  SDL_EVENTQUIT=12; //User-requested quit [C: SDL_QUIT]
  SDL_EVENTSYSWM=13; //System specific event [C: SDL_SYSWMEVENT]
  SDL_VIDEORESIZE=16; //User resized video mode
  //Events SDL_USEREVENT through SDL_MAXEVENTS-1 are for your use
  SDL_EVENTUSER=24; //[C: SDL_USEREVENT]
  //This last event is only for bounding internal arrays
  //It is the number of bits in the event mask datatype -- Uint32
  SDL_NUMEVENTS=32;

  SDL_ACTIVEEVENTMASK=1 SHL SDL_EVENTACTIVE;
  SDL_KEYDOWNMASK=1 SHL SDL_KEYDOWN;
  SDL_KEYUPMASK=1 SHL SDL_KEYUP;
  SDL_MOUSEMOTIONMASK=1 SHL SDL_MOUSEMOTION;
  SDL_MOUSEBUTTONDOWNMASK=1 SHL SDL_MOUSEBUTTONDOWN;
  SDL_MOUSEBUTTONUPMASK=1 SHL SDL_MOUSEBUTTONUP;
  SDL_MOUSEEVENTMASK=SDL_MOUSEMOTIONMASK OR SDL_MOUSEBUTTONDOWNMASK OR
    SDL_MOUSEBUTTONUPMASK;
  SDL_JOYAXISMOTIONMASK=1 SHL SDL_JOYAXISMOTION;
  SDL_JOYBALLMOTIONMASK=1 SHL SDL_JOYBALLMOTION;
  SDL_JOYHATMOTIONMASK=1 SHL SDL_JOYHATMOTION;
  SDL_JOYBUTTONDOWNMASK=1 SHL SDL_JOYBUTTONDOWN;
  SDL_JOYBUTTONUPMASK=1 SHL SDL_JOYBUTTONUP;
  SDL_JOYEVENTMASK=SDL_JOYAXISMOTIONMASK OR SDL_JOYBALLMOTIONMASK OR
    SDL_JOYHATMOTIONMASK OR SDL_JOYBUTTONDOWNMASK OR SDL_JOYBUTTONUPMASK;
  SDL_VIDEORESIZEMASK=1 SHL SDL_VIDEORESIZE;
  SDL_QUITMASK=1 SHL SDL_EVENTQUIT;
  SDL_SYSWMEVENTMASK=1 SHL SDL_EVENTSYSWM;
  SDL_ALLEVENTS=$FFFFFFFF;

  SDL_ADDEVENT=0;
  SDL_PEEKEVENT=1;
  SDL_GETEVENT=2;

  SDL_QUERY=-1;
  SDL_IGNORE=0;
  SDL_DISABLE=0;
  SDL_ENABLE=1;

  SDL_ALL_HOTKEYS=$FFFFFFFF;

  SDL_DEFAULT_REPEAT_DELAY=500;
  SDL_DEFAULT_REPEAT_INTERVAL=30;

  //The keyboard syms have been cleverly chosen to map to ASCII
  SDLK_UNKNOWN=0;
  SDLK_FIRST=0;
  SDLK_BACKSPACE=8;
  SDLK_TAB=9;
  SDLK_CLEAR=12;
  SDLK_RETURN=13;
  SDLK_PAUSE=19;
  SDLK_ESCAPE=27;
  SDLK_SPACE=32;
  SDLK_EXCLAIM=33;
  SDLK_QUOTEDBL=34;
  SDLK_HASH=35;
  SDLK_DOLLAR=36;
  SDLK_AMPERSAND=38;
  SDLK_QUOTE=39;
  SDLK_LEFTPAREN=40;
  SDLK_RIGHTPAREN=41;
  SDLK_ASTERISK=42;
  SDLK_PLUS=43;
  SDLK_COMMA=44;
  SDLK_MINUS=45;
  SDLK_PERIOD=46;
  SDLK_SLASH=47;
  SDLK_0=48;
  SDLK_1=49;
  SDLK_2=50;
  SDLK_3=51;
  SDLK_4=52;
  SDLK_5=53;
  SDLK_6=54;
  SDLK_7=55;
  SDLK_8=56;
  SDLK_9=57;
  SDLK_COLON=58;
  SDLK_SEMICOLON=59;
  SDLK_LESS=60;
  SDLK_EQUALS=61;
  SDLK_GREATER=62;
  SDLK_QUESTION=63;
  SDLK_AT=64;
  SDLK_LEFTBRACKET=91;
  SDLK_BACKSLASH=92;
  SDLK_RIGHTBRACKET=93;
  SDLK_CARET=94;
  SDLK_UNDERSCORE=95;
  SDLK_BACKQUOTE=96;
  SDLK_a=97;
  SDLK_b=98;
  SDLK_c=99;
  SDLK_d=100;
  SDLK_e=101;
  SDLK_f=102;
  SDLK_g=103;
  SDLK_h=104;
  SDLK_i=105;
  SDLK_j=106;
  SDLK_k=107;
  SDLK_l=108;
  SDLK_m=109;
  SDLK_n=110;
  SDLK_o=111;
  SDLK_p=112;
  SDLK_q=113;
  SDLK_r=114;
  SDLK_s=115;
  SDLK_t=116;
  SDLK_u=117;
  SDLK_v=118;
  SDLK_w=119;
  SDLK_x=120;
  SDLK_y=121;
  SDLK_z=122;
  SDLK_DELETE=127;

  //Numeric keypad
  SDLK_KP0=256;
  SDLK_KP1=257;
  SDLK_KP2=258;
  SDLK_KP3=259;
  SDLK_KP4=260;
  SDLK_KP5=261;
  SDLK_KP6=262;
  SDLK_KP7=263;
  SDLK_KP8=264;
  SDLK_KP9=265;
  SDLK_KP_PERIOD=266;
  SDLK_KP_DIVIDE=267;
  SDLK_KP_MULTIPLY=268;
  SDLK_KP_MINUS=269;
  SDLK_KP_PLUS=270;
  SDLK_KP_ENTER=271;
  SDLK_KP_EQUALS=272;

  //Arrows + Home/End pad
  SDLK_UP=273;
  SDLK_DOWN=274;
  SDLK_RIGHT=275;
  SDLK_LEFT=276;
  SDLK_INSERT=277;
  SDLK_HOME=278;
  SDLK_END=279;
  SDLK_PAGEUP=280;
  SDLK_PAGEDOWN=281;

  //Function keys
  SDLK_F1=282;
  SDLK_F2=283;
  SDLK_F3=284;
  SDLK_F4=285;
  SDLK_F5=286;
  SDLK_F6=287;
  SDLK_F7=288;
  SDLK_F8=289;
  SDLK_F9=290;
  SDLK_F10=291;
  SDLK_F11=292;
  SDLK_F12=293;
  SDLK_F13=294;
  SDLK_F14=295;
  SDLK_F15=296;

  //Key state modifier keys
  SDLK_NUMLOCK=300;
  SDLK_CAPSLOCK=301;
  SDLK_SCROLLOCK=302;
  SDLK_RSHIFT=303;
  SDLK_LSHIFT=304;
  SDLK_RCTRL=305;
  SDLK_LCTRL=306;
  SDLK_RALT=307;
  SDLK_LALT=308;
  SDLK_RMETA=309;
  SDLK_LMETA=310;
  SDLK_LSUPER=311; //Left "Windows" key
  SDLK_RSUPER=312; //Right "Windows" key
  SDLK_MODE=313; //"Alt Gr" key
  SDLK_COMPOSE=314; //Multi-key compose key

  //Miscellaneous function keys
  SDLK_HELP=315;
  SDLK_PRINT=316;
  SDLK_SYSREQ=317;
  SDLK_BREAK=318;
  SDLK_MENU=319;
  SDLK_POWER=320; //Power Macintosh power key
  SDLK_EURO=321; //Some european keyboards

  SDLK_LAST=322;

  //Enumeration of valid key mods (possibly OR'd together)
  KMOD_NONE=$0000;
  KMOD_LSHIFT=$0001;
  KMOD_RSHIFT=$0002;
  KMOD_LCTRL=$0040;
  KMOD_RCTRL=$0080;
  KMOD_LALT=$0100;
  KMOD_RALT=$0200;
  KMOD_LMETA=$0400;
  KMOD_RMETA=$0800;
  KMOD_NUM=$1000;
  KMOD_CAPS=$2000;
  KMOD_MODE=$4000;
  KMOD_RESERVED=$8000;

  KMOD_CTRL=KMOD_LCTRL OR KMOD_RCTRL;
  KMOD_SHIFT=KMOD_LSHIFT OR KMOD_RSHIFT;
  KMOD_ALT=KMOD_LALT OR KMOD_RALT;
  KMOD_META=KMOD_LMETA OR KMOD_RMETA;

  SDL_MAJOR_VERSION=1;
  SDL_MINOR_VERSION=1;
  SDL_PATCHLEVEL=8;

  //This is the OS scheduler timeslice, in milliseconds
  SDL_TIMESLICE=10;
  //This is the maximum resolution of the SDL timer on all platforms
  TIMER_RESOLUTION=10; //experimentally determined

  SDL_PRESSED=1;
  SDL_RELEASED=0;
  //Used as a mask when testing buttons in buttonstate
  //Button 1: Left mouse button
  //Button 2: Middle mouse button
  //Button 3: Right mouse button
  SDL_BUTTON_LEFT=1;
  SDL_BUTTON_MIDDLE=2;
  SDL_BUTTON_RIGHT=3;
  SDL_BUTTON_LMASK=SDL_PRESSED;
  SDL_BUTTON_MMASK=SDL_PRESSED SHL 1;
  SDL_BUTTON_RMASK=SDL_PRESSED SHL 2;

  SDL_HAT_CENTERED=$00;
  SDL_HAT_UP=$01;
  SDL_HAT_RIGHT=$02;
  SDL_HAT_DOWN=$04;
  SDL_HAT_LEFT=$08;
  SDL_HAT_RIGHTUP=SDL_HAT_RIGHT OR SDL_HAT_UP;
  SDL_HAT_RIGHTDOWN=SDL_HAT_RIGHT OR SDL_HAT_DOWN;
  SDL_HAT_LEFTUP=SDL_HAT_LEFT OR SDL_HAT_UP;
  SDL_HAT_LEFTDOWN=SDL_HAT_LEFT OR SDL_HAT_DOWN;

  SDL_LOGPAL=$01;
  SDL_PHYSPAL=$02;

  //These are the currently supported flags for the SDL_Surface
  //Available for SDL_CreateRGBSurface() or SDL_SetVideoMode()
  SDL_SWSURFACE=$00000000; //Surface is in system memory
  SDL_HWSURFACE=$00000001; //Surface is in video memory
  SDL_ASYNCBLIT=$00000004; //Use asynchronous blits if possible
  //Available for SDL_SetVideoMode()
  SDL_ANYFORMAT=$10000000; //Allow any video depth/pixel-format
  SDL_HWPALETTE=$20000000; //Surface has exclusive palette
  SDL_DOUBLEBUF=$40000000; //Set up double-buffered video mode
  SDL_FULLSCREEN=$80000000; //Surface is a full screen display
  SDL_OPENGL=$00000002; //Create an OpenGL rendering context
  SDL_OPENGLBLIT=$0000000A; //Create an OpenGL rendering context and use it for blitting
  SDL_RESIZABLE=$00000010; //This video mode may be resized
  SDL_NOFRAME=$00000020; //No window caption or edge frame
  //Used internally (read-only)
  SDL_HWACCEL=$00000100; //Blit uses hardware acceleration
  SDL_SRCCOLORKEY=$00001000; //Blit uses a source color key
  SDL_RLEACCELOK=$00002000; //Private flag
  SDL_RLEACCEL=$00004000; //Surface is RLE encoded
  SDL_SRCALPHA=$00010000; //Blit uses source alpha blending
  SDL_PREALLOC=$01000000; //Surface uses preallocated memory

  //Transparency definitions: These define alpha as the opacity of a surface
  SDL_ALPHA_OPAQUE=255;
  SDL_ALPHA_TRANSPARENT=0;

  //The most common video overlay formats
  SDL_YV12_OVERLAY=$32315659; //Planar mode: Y + V + U  (3 planes)
  SDL_IYUV_OVERLAY=$56555949; //Planar mode: Y + U + V  (3 planes)
  SDL_YUY2_OVERLAY=$32595559; //Packed mode: Y0+U0+Y1+V0 (1 plane)
  SDL_UYVY_OVERLAY=$59565955; //Packed mode: U0+Y0+V0+Y1 (1 plane)
  SDL_YVYU_OVERLAY=$55595659; //Packed mode: Y0+V0+Y1+U0 (1 plane)

  SDL_GL_RED_SIZE=0;
  SDL_GL_GREEN_SIZE=1;
  SDL_GL_BLUE_SIZE=2;
  SDL_GL_ALPHA_SIZE=3;
  SDL_GL_BUFFER_SIZE=4;
  SDL_GL_DOUBLEBUFFER=5;
  SDL_GL_DEPTH_SIZE=6;
  SDL_GL_STENCIL_SIZE=7;
  SDL_GL_ACCUM_RED_SIZE=8;
  SDL_GL_ACCUM_GREEN_SIZE=9;
  SDL_GL_ACCUM_BLUE_SIZE=10;
  SDL_GL_ACCUM_ALPHA_SIZE=11;

type
  plongint=^longint;

  pSDL_version=^SDL_version;
  SDL_version=record
    major:byte;
    minor:byte;
    patch:byte;
  end;

  ppSDL_Rect=^pSDL_Rect;
  pSDL_Rect=^SDL_Rect;
  SDL_Rect=record
    x,y:smallint;
    w,h:word;
  end;

  SDL_Color=record
    r,g,b,unused:byte;
  end;

  SDL_Palette=record
    ncolors:longint;
    colors:^SDL_Color;
  end;

  //Everything in the pixel format structure is read-only
  pSDL_PixelFormat=^SDL_PixelFormat;
  SDL_PixelFormat=record
    palette:^SDL_Palette;
    BitsPerPixel:byte;
    BytesPerPixel:byte;
    Rloss,Gloss,Bloss,Aloss:byte;
    Rshift,Gshift,Bshift,Ashift:byte;
    Rmask,Gmask,Bmask,Amask:longint;
    colorkey:longint; //RGB color key information
    alpha:byte; //Alpha value information (per-surface alpha)
  end;

  _ppixels=^_tpixels;
  _tpixels=array [0..16384*1024-1] of byte;
  pSDL_Surface=^SDL_Surface;
  SDL_Surface=record
    flags:longint;
    format:^SDL_PixelFormat;
    w,h:longint;
    pitch:word;
    pixels:_ppixels;
    offset:longint;
    hwdata:pointer;
    clip_rect:SDL_Rect;
    unused1:longint;
    locked:longint;
    map:pointer;
    format_version:longint;
    refcount:longint;
  end;

  pSDL_VideoInfo=^SDL_VideoInfo;
  SDL_VideoInfo=record
    {
      Uint32 hw_available:1; Flag: Can you create hardware surfaces?
      Uint32 wm_available:1; Flag: Can you talk to a window manager?
      Uint32 UnusedBits1:6;
    }
    flag1:byte;
    {
      Uint32 UnusedBits2:1;
      Uint32 blit_hw:1; Flag: Accelerated blits HW --> HW
      Uint32 blit_hw_CC:1; Flag: Accelerated blits with Colorkey
      Uint32 blit_hw_A:1; Flag: Accelerated blits with Alpha
      Uint32 blit_sw:1; Flag: Accelerated blits SW --> HW
      Uint32 blit_sw_CC:1; Flag: Accelerated blits with Colorkey
      Uint32 blit_sw_A:1; Flag: Accelerated blits with Alpha
      Uint32 blit_fill:1; Flag: Accelerated color fill
    }
    flag2:byte;
    flag3:word; //unusedbits3
    video_mem:longint; //The total amount of video memory (in K)
    vfmt:^SDL_PixelFormat; //Value: The format of the video surface
  end;

  //The YUV hardware video overlay
  pSDL_Overlay=^SDL_Overlay;
  SDL_Overlay=record
    format:longint; //read-only
    w,h:longint; //read-only
    planes:longint; //read-only
    pitches:^word; //read-only
    pixels:^_ppixels; //read-only
    //Hardware-specific surface info
    hwfuncs:pointer;
    hwdata:pointer;
    //Special flags
    hw_overlay:longint; //:1 Flag: This overlay hardware accelerated?
  end;

  //Keysym structure
  // - The scancode is hardware dependent, and should not be used by general
  //   applications.  If no hardware scancode is available, it will be 0.
  // - The 'unicode' translated character is only available when character
  //   translation is enabled by the SDL_EnableUNICODE() API.  If non-zero,
  //   this is a UNICODE character corresponding to the keypress.  If the
  //   high 9 bits of the character are 0, then this maps to the equivalent
  //   ASCII character:
  //     char ch;
  //     if ( (keysym.unicode & 0xFF80) == 0 ) {
  //       ch = keysym.unicode & 0x7F;
  //     } else {
  //       An international character..
  //     }
  SDL_keysym=record
    scancode:byte; //hardware specific scancode
    sym:longint; //SDL virtual keysym
    modif:longint; //current key modifiers
    unicode:word; //translated character
  end;

  //The windows custom event structure
  SDL_SysWMmsg=record
    version:SDL_version;
    hwnd:longint; //The window for the message
    msg:longint; //The type of message
    wparam:longint;
    lparam:longint;
  end;

  pSDL_SysWMinfo=^SDL_SysWMinfo;
  SDL_SysWMinfo=record
    version:SDL_version;
    window:longint;
  end;

  //Application visibility event structure
  SDL_ActiveEvent=record
    typ:byte; //SDL_ACTIVEEVENT
    gain:byte; //Whether given states were gained or lost (1/0)
    state:byte; //A mask of the focus states
  end;

  //Keyboard event structure
  SDL_KeyboardEvent=record
    typ:byte; //SDL_KEYDOWN or SDL_KEYUP
    which:byte; //The keyboard device index
    state:byte; //SDL_PRESSED or SDL_RELEASED
    keysym:SDL_keysym;
  end;

  //Mouse motion event structure
  SDL_MouseMotionEvent=record
    typ:byte; //SDL_MOUSEMOTION
    which:byte; //The mouse device index
    state:byte; //The current button state
    x,y:word; //The X/Y coordinates of the mouse
    xrel:smallint; //The relative motion in the X direction
    yrel:smallint; //The relative motion in the Y direction
  end;

  //Mouse button event structure
  SDL_MouseButtonEvent=record
    typ:byte; //SDL_MOUSEBUTTONDOWN or SDL_MOUSEBUTTONUP
    which:byte; //The mouse device index
    button:byte; //The mouse button index
    state:byte;	//SDL_PRESSED or SDL_RELEASED
    x,y:word; //The X/Y coordinates of the mouse at press time
  end;

  //Joystick axis motion event structure
  SDL_JoyAxisEvent=record
    typ:byte; //SDL_JOYAXISMOTION
    which:byte; //The joystick device index
    axis:byte; //The joystick axis index
    value:smallint; //The axis value (range: -32768 to 32767)
  end;

  //Joystick trackball motion event structure
  SDL_JoyBallEvent=record
    typ:byte; //SDL_JOYBALLMOTION
    which:byte; //The joystick device index
    ball:byte; //The joystick trackball index
    xrel:smallint; //The relative motion in the X direction
    yrel:smallint; //The relative motion in the Y direction
  end;

  //Joystick hat position change event structure
  SDL_JoyHatEvent=record
    typ:byte; //SDL_JOYHATMOTION
    which:byte; //The joystick device index
    hat:byte; //The joystick hat index
    value:byte; //The hat position value: 8 1 2 / 7 0 3 / 6 5 4 [0=centered]
  end;

  //Joystick button event structure
  SDL_JoyButtonEvent=record
    typ:byte; //SDL_JOYBUTTONDOWN or SDL_JOYBUTTONUP
    which:byte; //The joystick device index
    button:byte; //The joystick button index
    state:byte; //SDL_PRESSED or SDL_RELEASED
  end;

  //The "window resized" event
  //When you get this event, you are responsible for setting a new video
  //mode with the new width and height.
  SDL_ResizeEvent=record
    typ:byte; //SDL_VIDEORESIZE
    w:longint; //New width
    h:longint; //New height
  end;

  //The "quit requested" event
  SDL_QuitEvent=record
    typ:byte; //SDL_QUIT
  end;

  //A user-defined event type
  SDL_UserEvent=record
    typ:byte; //SDL_USEREVENT through SDL_NUMEVENTS-1
    code:longint; //User defined event code
    data1:pointer; //User defined data pointer
    data2:pointer; //User defined data pointer
  end;

  SDL_SysWMEvent=record
    typ:byte;
    msg:^SDL_SysWMmsg;
  end;

  //General event structure
  pSDL_Event=^SDL_Event;
  SDL_Event=record
    case integer of
      0:(typ:byte);
      1:(active:SDL_ActiveEvent);
      2:(key:SDL_KeyboardEvent);
      3:(motion:SDL_MouseMotionEvent);
      4:(button:SDL_MouseButtonEvent);
      5:(jaxis:SDL_JoyAxisEvent);
      6:(jball:SDL_JoyBallEvent);
      7:(jhat:SDL_JoyHatEvent);
      8:(jbutton:SDL_JoyButtonEvent);
      9:(resize:SDL_ResizeEvent);
      10:(quit:SDL_QuitEvent);
      11:(user:SDL_UserEvent);
      12:(syswm:SDL_SysWMEvent);
    end;

  SDL_EventFilter=function(event:pSDL_Event):longint;cdecl;

  SDL_TimerCallback=function(interval:longint):longint;cdecl;
  SDL_NewTimerCallback=function(interval:longint;param:pointer):longint;cdecl;
  SDL_TimerID=longint;

  pSDL_Cursor=^SDL_Cursor;
  SDL_Cursor=record
    area:SDL_Rect; //The area of the mouse cursor
    hot_x,hot_y:smallint; //The "tip" of the cursor
    data:pointer; //B/W cursor data
    mask:pointer; //B/W cursor mask
    save:array [0..1] of pointer; //Place to save cursor area
    wm_cursor:pointer; //Window-manager cursor
  end;

  SDL_Joystick=longint;

function SDL_Init(flags:longint):longint;cdecl;
function SDL_InitSubSystem(flags:longint):longint;cdecl;
procedure SDL_QuitSubSystem(flags:longint);cdecl;
function SDL_WasInit(flags:longint):longint;cdecl;
procedure SDL_Quit;cdecl;

function SDL_GetAppState:byte;cdecl;

procedure SDL_PumpEvents;cdecl;
function SDL_PeepEvents(event:pSDL_Event;numevents:longint;
  action:longint;mask:longint):longint;cdecl;
function SDL_PollEvent(event:pSDL_Event):longint;cdecl;
function SDL_WaitEvent(event:pSDL_Event):longint;cdecl;
function SDL_PushEvent(event:pSDL_Event):longint;cdecl;
procedure SDL_SetEventFilter(filter:SDL_EventFilter);cdecl;
function SDL_GetEventFilter:SDL_EventFilter;cdecl;
function SDL_EventState(typ:byte;state:longint):byte;cdecl;

function SDL_EnableUNICODE(enable:longint):longint;cdecl;
function SDL_EnableKeyRepeat(delay,interval:longint):longint;cdecl;
function SDL_GetKeyState(numkeys:plongint):pointer;cdecl;
function SDL_GetModState:longint;cdecl;
procedure SDL_SetModState(modstate:longint);cdecl;
function SDL_GetKeyName(key:longint):pchar;cdecl;

function SDL_RegisterApp(name:pchar;style:longint;hinst:pointer):longint;cdecl;

function SDL_GetWMInfo(info:pSDL_SysWMinfo):longint;cdecl;

function SDL_Linked_Version:pSDL_version;cdecl;

function SDL_GetTicks:longint;cdecl;
procedure SDL_Delay(ms:longint);cdecl;
function SDL_SetTimer(interval:longint;callback:SDL_TimerCallback):longint;cdecl;
function SDL_AddTimer(interval:longint;callback:SDL_NewTimerCallback;param:pointer):longint;cdecl;
function SDL_RemoveTimer(t:longint):longbool;cdecl;

function SDL_GetMouseState(var x,y:longint):byte;cdecl;
function SDL_GetRelativeMouseState(var x,y:longint):byte;cdecl;
procedure SDL_WarpMouse(x,y:smallint);cdecl;
function SDL_CreateCursor(data,mask:pointer;w,h,hot_x,hot_y:longint):pSDL_Cursor;cdecl;
procedure SDL_SetCursor(cursor:pSDL_Cursor);cdecl;
function SDL_GetCursor:pSDL_Cursor;cdecl;
procedure SDL_FreeCursor(cursor:pSDL_Cursor);cdecl;
function SDL_ShowCursor(toggle:longint):longint;cdecl;

function SDL_NumJoysticks:longint;cdecl;
function SDL_JoystickName(device_index:longint):pchar;cdecl;
function SDL_JoystickOpen(device_index:longint):longint;cdecl;
function SDL_JoystickOpened(device_index:longint):longbool;cdecl;
function SDL_JoystickIndex(joystick:longint):longint;cdecl;
function SDL_JoystickNumAxes(joystick:longint):longint;cdecl;
function SDL_JoystickNumBalls(joystick:longint):longint;cdecl;
function SDL_JoystickNumHats(joystick:longint):longint;cdecl;
function SDL_JoystickNumButtons(joystick:longint):longint;cdecl;
procedure SDL_JoystickUpdate;cdecl;
function SDL_JoystickEventState(state:longint):longint;cdecl;
function SDL_JoystickGetAxis(joystick:longint;axis:longint):smallint;cdecl;
function SDL_JoystickGetHat(joystick:longint;hat:longint):byte;cdecl;
function SDL_JoystickGetBall(joystick:longint;ball:longint;var dx,dy:longint):longint;cdecl;
function SDL_JoystickGetButton(joystick:longint;button:longint):byte;cdecl;
procedure SDL_JoystickClose(joystick:longint);cdecl;

function SDL_MUSTLOCK(surface:pSDL_Surface):boolean;

function SDL_VideoInit(driver_name:pchar;flags:longint):longint;cdecl;
procedure SDL_VideoQuit;cdecl;
function SDL_VideoDriverName(namebuf:pchar;maxlen:longint):pchar;cdecl;
function SDL_GetVideoSurface:pSDL_Surface;cdecl;
function SDL_GetVideoInfo:pSDL_VideoInfo;cdecl;
function SDL_SetVideoModeOK(width,height,bpp:longint;flags:cardinal):longint;cdecl;
function SDL_ListModes(format:pSDL_PixelFormat;flags:longint):ppSDL_Rect;cdecl;
function SDL_SetVideoMode(width,height,bpp:longint;flags:cardinal):pSDL_Surface;cdecl;
procedure SDL_UpdateRects(screen:pSDL_Surface;numrects:longint;rects:pointer);cdecl;
procedure SDL_UpdateRect(screen:pSDL_Surface;x,y:smallint;w,h:longint);cdecl;
function SDL_Flip(screen:pSDL_Surface):longint;cdecl;
function SDL_SetColors(surface:pSDL_Surface;colors:pointer;firstcolor,ncolors:longint):longint;cdecl;
function SDL_SetPalette(surface:pSDL_Surface;flags:longint;colors:pointer;firstcolor,ncolors:longint):longint;cdecl;
function SDL_MapRGB(format:pSDL_PixelFormat;r,g,b:byte):longint;cdecl;
function SDL_MapRGBA(format:pSDL_PixelFormat;r,g,b,a:byte):longint;cdecl;
procedure SDL_GetRGB(pixel:longint;fmt:pSDL_PixelFormat;var r,g,b:byte);cdecl;
procedure SDL_GetRGBA(pixel:longint;fmt:pSDL_PixelFormat;var r,g,b,a:byte);cdecl;
function SDL_CreateRGBSurface(flags,width,height,depth,rmask,gmask,bmask,amask:longint):pSDL_Surface;cdecl;
function SDL_CreateRGBSurfaceFrom(pixels:pointer;flags,width,height,depth,rmask,gmask,bmask,amask:longint):pSDL_Surface;cdecl;
procedure SDL_FreeSurface(surface:pSDL_Surface);cdecl;
function SDL_LockSurface(surface:pSDL_Surface):longint;cdecl;
procedure SDL_UnlockSurface(surface:pSDL_Surface);cdecl;
function SDL_SetColorKey(surface:pSDL_Surface;flag,key:longint):longint;cdecl;
function SDL_SetAlpha(surface:pSDL_Surface;flag:longint;alpha:byte):longint;cdecl;
function SDL_SetClipRect(surface:pSDL_Surface;rect:pSDL_Rect):longbool;cdecl;
procedure SDL_GetClipRect(surface:pSDL_Surface;rect:pSDL_Rect);cdecl;
function SDL_UpperBlit(src:pSDL_Surface;srcrect:pSDL_Rect;dst:pSDL_Surface;dstrect:pSDL_Rect):longint;cdecl;
procedure sdl_blit(src:pSDL_Surface;srcrect:pSDL_Rect;dst:pSDL_Surface;dstrect:pSDL_Rect);
function SDL_FillRect(dst:pSDL_Surface;rect:pSDL_Rect;color:longint):longint;cdecl;
function SDL_DisplayFormat(surface:pSDL_Surface):pSDL_Surface;cdecl;
function SDL_DisplayFormatAlpha(surface:pSDL_Surface):pSDL_Surface;cdecl;
function SDL_CreateYUVOverlay(width,height,format:longint;display:pSDL_Surface):pSDL_Overlay;cdecl;
function SDL_LockYUVOverlay(overlay:pSDL_Overlay):longint;cdecl;
procedure SDL_UnlockYUVOverlay(overlay:pSDL_Overlay);cdecl;
function SDL_DisplayYUVOverlay(overlay:pSDL_Overlay;dstrect:pSDL_Rect):longint;cdecl;
procedure SDL_FreeYUVOverlay(overlay:pSDL_Overlay);cdecl;
procedure SDL_WM_SetCaption(title,icon:pchar);cdecl;
procedure SDL_WM_GetCaption(var title,icon:pchar);cdecl;
procedure SDL_WM_SetIcon(icon:pSDL_Surface;mask:pointer);cdecl;
function SDL_WM_IconifyWindow:longint;cdecl;

function SDL_GetError:pchar;cdecl;
function SDL_GL_LoadLibrary(path:pchar):longint;cdecl;
function SDL_GL_GetProcAddress(proc:pchar):pointer;cdecl;
function SDL_GL_SetAttribute(attr,value:longint):longint;cdecl;
function SDL_GL_GetAttribute(attr:longint;var value:longint):longint;cdecl;
procedure SDL_GL_SwapBuffers;cdecl;
procedure SDL_SetModuleHandle(p:pointer);cdecl;

implementation

{$ifdef linux}
const
  sdldll='libSDL.so';
{$else}
const
  sdldll='sdl.dll';
{$endif}

function SDL_Init(flags:longint):longint;cdecl;external sdldll;
function SDL_InitSubSystem(flags:longint):longint;cdecl;external sdldll;
procedure SDL_QuitSubSystem(flags:longint);cdecl;external sdldll;
function SDL_WasInit(flags:longint):longint;cdecl;external sdldll;
procedure SDL_Quit;cdecl;external sdldll;

function SDL_GetAppState:byte;cdecl;external sdldll;

procedure SDL_PumpEvents;cdecl;external sdldll;
function SDL_PeepEvents(event:pSDL_Event;numevents:longint;
  action:longint;mask:longint):longint;cdecl;external sdldll;
function SDL_PollEvent(event:pSDL_Event):longint;cdecl;external sdldll;
function SDL_WaitEvent(event:pSDL_Event):longint;cdecl;external sdldll;
function SDL_PushEvent(event:pSDL_Event):longint;cdecl;external sdldll;
procedure SDL_SetEventFilter(filter:SDL_EventFilter);cdecl;external sdldll;
function SDL_GetEventFilter:SDL_EventFilter;cdecl;external sdldll;
function SDL_EventState(typ:byte;state:longint):byte;cdecl;external sdldll;

function SDL_EnableUNICODE(enable:longint):longint;cdecl;external sdldll;
function SDL_EnableKeyRepeat(delay,interval:longint):longint;cdecl;external sdldll;
function SDL_GetKeyState(numkeys:plongint):pointer;cdecl;external sdldll;
function SDL_GetModState:longint;cdecl;external sdldll;
procedure SDL_SetModState(modstate:longint);cdecl;external sdldll;
function SDL_GetKeyName(key:longint):pchar;cdecl;external sdldll;

function SDL_RegisterApp(name:pchar;style:longint;hinst:pointer):longint;cdecl;external sdldll;

function SDL_GetWMInfo(info:pSDL_SysWMinfo):longint;cdecl;external sdldll;

function SDL_Linked_Version:pSDL_version;cdecl;external sdldll;

function SDL_GetTicks:longint;cdecl;external sdldll;
procedure SDL_Delay(ms:longint);cdecl;external sdldll;
function SDL_SetTimer(interval:longint;callback:SDL_TimerCallback):longint;cdecl;external sdldll;
function SDL_AddTimer(interval:longint;callback:SDL_NewTimerCallback;param:pointer):longint;cdecl;external sdldll;
function SDL_RemoveTimer(t:longint):longbool;cdecl;external sdldll;

function SDL_GetMouseState(var x,y:longint):byte;cdecl;external sdldll;
function SDL_GetRelativeMouseState(var x,y:longint):byte;cdecl;external sdldll;
procedure SDL_WarpMouse(x,y:smallint);cdecl;external sdldll;
function SDL_CreateCursor(data,mask:pointer;w,h,hot_x,hot_y:longint):pSDL_Cursor;cdecl;external sdldll;
procedure SDL_SetCursor(cursor:pSDL_Cursor);cdecl;external sdldll;
function SDL_GetCursor:pSDL_Cursor;cdecl;external sdldll;
procedure SDL_FreeCursor(cursor:pSDL_Cursor);cdecl;external sdldll;
function SDL_ShowCursor(toggle:longint):longint;cdecl;external sdldll;

function SDL_NumJoysticks:longint;cdecl;external sdldll;
function SDL_JoystickName(device_index:longint):pchar;cdecl;external sdldll;
function SDL_JoystickOpen(device_index:longint):longint;cdecl;external sdldll;
function SDL_JoystickOpened(device_index:longint):longbool;cdecl;external sdldll;
function SDL_JoystickIndex(joystick:longint):longint;cdecl;external sdldll;
function SDL_JoystickNumAxes(joystick:longint):longint;cdecl;external sdldll;
function SDL_JoystickNumBalls(joystick:longint):longint;cdecl;external sdldll;
function SDL_JoystickNumHats(joystick:longint):longint;cdecl;external sdldll;
function SDL_JoystickNumButtons(joystick:longint):longint;cdecl;external sdldll;
procedure SDL_JoystickUpdate;cdecl;external sdldll;
function SDL_JoystickEventState(state:longint):longint;cdecl;external sdldll;
function SDL_JoystickGetAxis(joystick:longint;axis:longint):smallint;cdecl;external sdldll;
function SDL_JoystickGetHat(joystick:longint;hat:longint):byte;cdecl;external sdldll;
function SDL_JoystickGetBall(joystick:longint;ball:longint;var dx,dy:longint):longint;cdecl;external sdldll;
function SDL_JoystickGetButton(joystick:longint;button:longint):byte;cdecl;external sdldll;
procedure SDL_JoystickClose(joystick:longint);cdecl;external sdldll;

function SDL_MUSTLOCK(surface:pSDL_Surface):boolean;
begin
  result:=(surface^.offset<>0) or
  ((surface^.flags and (SDL_HWSURFACE or SDL_ASYNCBLIT or SDL_RLEACCEL))<>0);
end;

function SDL_VideoInit(driver_name:pchar;flags:longint):longint;cdecl;external sdldll;
procedure SDL_VideoQuit;cdecl;external sdldll;
function SDL_VideoDriverName(namebuf:pchar;maxlen:longint):pchar;cdecl;external sdldll;
function SDL_GetVideoSurface:pSDL_Surface;cdecl;external sdldll;
function SDL_GetVideoInfo:pSDL_VideoInfo;cdecl;external sdldll;
function SDL_SetVideoModeOK(width,height,bpp:longint;flags:cardinal):longint;cdecl;external sdldll;
function SDL_ListModes(format:pSDL_PixelFormat;flags:longint):ppSDL_Rect;cdecl;external sdldll;
function SDL_SetVideoMode(width,height,bpp:longint;flags:cardinal):pSDL_Surface;cdecl;external sdldll;
procedure SDL_UpdateRects(screen:pSDL_Surface;numrects:longint;rects:pointer);cdecl;external sdldll;
procedure SDL_UpdateRect(screen:pSDL_Surface;x,y:smallint;w,h:longint);cdecl;external sdldll;
function SDL_Flip(screen:pSDL_Surface):longint;cdecl;external sdldll;
function SDL_SetColors(surface:pSDL_Surface;colors:pointer;firstcolor,ncolors:longint):longint;cdecl;external sdldll;
function SDL_SetPalette(surface:pSDL_Surface;flags:longint;colors:pointer;firstcolor,ncolors:longint):longint;cdecl;external sdldll;
function SDL_MapRGB(format:pSDL_PixelFormat;r,g,b:byte):longint;cdecl;external sdldll;
function SDL_MapRGBA(format:pSDL_PixelFormat;r,g,b,a:byte):longint;cdecl;external sdldll;
procedure SDL_GetRGB(pixel:longint;fmt:pSDL_PixelFormat;var r,g,b:byte);cdecl;external sdldll;
procedure SDL_GetRGBA(pixel:longint;fmt:pSDL_PixelFormat;var r,g,b,a:byte);cdecl;external sdldll;
function SDL_CreateRGBSurface(flags,width,height,depth,rmask,gmask,bmask,amask:longint):pSDL_Surface;cdecl;external sdldll;
function SDL_CreateRGBSurfaceFrom(pixels:pointer;flags,width,height,depth,rmask,gmask,bmask,
  amask:longint):pSDL_Surface;cdecl;external sdldll;
procedure SDL_FreeSurface(surface:pSDL_Surface);cdecl;external sdldll;
function SDL_LockSurface(surface:pSDL_Surface):longint;cdecl;external sdldll;
procedure SDL_UnlockSurface(surface:pSDL_Surface);cdecl;external sdldll;
function SDL_SetColorKey(surface:pSDL_Surface;flag,key:longint):longint;cdecl;external sdldll;
function SDL_SetAlpha(surface:pSDL_Surface;flag:longint;alpha:byte):longint;cdecl;external sdldll;
function SDL_SetClipRect(surface:pSDL_Surface;rect:pSDL_Rect):longbool;cdecl;external sdldll;
procedure SDL_GetClipRect(surface:pSDL_Surface;rect:pSDL_Rect);cdecl;external sdldll;
function SDL_FillRect(dst:pSDL_Surface;rect:pSDL_Rect;color:longint):longint;cdecl;external sdldll;
function SDL_DisplayFormat(surface:pSDL_Surface):pSDL_Surface;cdecl;external sdldll;
function SDL_DisplayFormatAlpha(surface:pSDL_Surface):pSDL_Surface;cdecl;external sdldll;
function SDL_CreateYUVOverlay(width,height,format:longint;display:pSDL_Surface):pSDL_Overlay;cdecl;external sdldll;
function SDL_LockYUVOverlay(overlay:pSDL_Overlay):longint;cdecl;external sdldll;
procedure SDL_UnlockYUVOverlay(overlay:pSDL_Overlay);cdecl;external sdldll;
function SDL_DisplayYUVOverlay(overlay:pSDL_Overlay;dstrect:pSDL_Rect):longint;cdecl;external sdldll;
procedure SDL_FreeYUVOverlay(overlay:pSDL_Overlay);cdecl;external sdldll;
procedure SDL_WM_SetCaption(title,icon:pchar);cdecl;external sdldll;
procedure SDL_WM_GetCaption(var title,icon:pchar);cdecl;external sdldll;
procedure SDL_WM_SetIcon(icon:pSDL_Surface;mask:pointer);cdecl;external sdldll;
function SDL_WM_IconifyWindow:longint;cdecl;external sdldll;
function SDL_UpperBlit(src:pSDL_Surface;srcrect:pSDL_Rect;dst:pSDL_Surface;dstrect:pSDL_Rect):longint;cdecl;external sdldll;

procedure sdl_blit(src:pSDL_Surface;srcrect:pSDL_Rect;dst:pSDL_Surface;dstrect:pSDL_Rect);
begin
  sdl_upperblit(src,srcrect,dst,dstrect);
end;

function SDL_GetError:pchar;cdecl;external sdldll;
function SDL_GL_LoadLibrary(path:pchar):longint;cdecl;external sdldll;
function SDL_GL_GetProcAddress(proc:pchar):pointer;cdecl;external sdldll;
function SDL_GL_SetAttribute(attr,value:longint):longint;cdecl;external sdldll;
function SDL_GL_GetAttribute(attr:longint;var value:longint):longint;cdecl;external sdldll;
procedure SDL_GL_SwapBuffers;cdecl;external sdldll;
procedure SDL_SetModuleHandle(p:pointer);cdecl;external sdldll;

end.
