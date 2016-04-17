; Hello World for Intel Assembler (MSDOS)
; from http://www.roesler-ac.de/wolfram/hello.htm

mov ax,cs
mov ds,ax
mov ah,9
mov dx, offset Hello
int 21h
xor ax,ax
int 21h

Hello:
  db "Hello World!",13,10,"$"
