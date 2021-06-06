unit rle;

interface

function RLECompress(var src,dest;size:longint):longint;assembler;pascal;
function RLEDecompress(var src,dest;size:longint):longint;assembler;pascal;

implementation

function RLECompress(var src,dest;size:longint):longint;assembler;pascal;
asm
  push ebx
  push esi
  push edi
  mov eax,size
  or eax,eax
  jne @sizg0
  xor eax,eax
  jmp @ret
@sizg0:
  push ebp
  mov esi,src
  mov edi,dest
  mov ebp,edi
  push ebp
  mov ebp,esi
  xor ecx,ecx
  xor edx,edx
@comp:
  push eax
  mov al,[esi]
  inc esi
  or cl,cl
  jne @rcnot0
  mov cl,1
  mov dl,al
  jmp @rcn0cont
@rcnot0:
  cmp al,dl
  jne @l1
  cmp cl,3fh
  jnb @l1
  jmp @incrc
@l1:
  cmp cl,1
  jna @l2
  jmp @l4
@l2:
  test dl,80h
  jz @l3
  test dl,40h
  jz @l3
@l4:
  mov bl,al
  mov al,cl
  or al,0c0h
  mov [edi],al
  inc edi
  mov al,bl
@l3:
  mov [edi],dl
  inc edi
  mov cl,1
  mov dl,al
  jmp @rcn0cont
@incrc:
  inc cl
@rcn0cont:
  mov ebx,esi
  sub ebx,ebp
  pop eax
  cmp ebx,eax
  jb @comp
  cmp cl,1
  jna @l5
  jmp @l7
@l5:
  test dl,80h
  jz @l6
  test dl,40h
  jz @l6
@l7:
  mov al,cl
  or al,0c0h
  mov [edi],al
  inc edi
@l6:
  mov al,dl
  mov [edi],al
  inc edi
  pop ebp
  sub edi,ebp
  mov eax,edi
  pop ebp
@ret:
  pop edi
  pop esi
  pop ebx
end;

function RLEDecompress(var src,dest;size:longint):longint;assembler;pascal;
asm
  push ebx
  push esi
  push edi
  mov edx,size
  or edx,edx
  jne @sizg0
  xor eax,eax
  jmp @ret
@sizg0:
  mov esi,src
  mov edi,dest
  push edi
  mov ebx,esi
@decomp:
  push edx
  mov al,[esi]
  inc esi
  test al,80h
  jz @neq
  test al,40h
  jz @neq
  mov dl,al
  and dl,3fh
  mov al,[esi]
  inc esi
  jmp @cont
@neq:
  mov dl,1
@cont:
  xor ecx,ecx
  mov cl,dl
  cld
  rep stosb
  mov eax,esi
  sub eax,ebx
  pop edx
  cmp eax,edx
  jb @decomp
  pop ebx
  sub edi,ebx
  mov eax,edi
@ret:
  pop edi
  pop esi
  pop ebx
end;

end.
