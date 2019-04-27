model tiny
.data
    ASCII db "0000",0Dh,0Ah,"$" ; buffer for ASCII string
    old   dd  0 

.code
ORG 100h
    


start:
mov     ax,  352Fh               ; получение адреса старого обработчика
    int     21h                      ; 
    mov     word ptr old,  bx        ; сохранение смещения обработчика
    mov     word ptr old + 2,  es    ; сохранение сегмента обработчика
    mov ax, word ptr old

    call print_ax
    




    mov     ax,  352Fh               ; получение адреса старого обработчика
    int     21h                      ; 
    mov     word ptr old,  bx        ; сохранение смещения обработчика
    mov     word ptr old + 2,  es    ; сохранение сегмента обработчика
    mov dx, word ptr old


    ret
print_ax proc
    mov di,OFFSET ASCII
    mov cl,4
P1: rol ax,4
    mov bl,al
    and bl,0Fh          ; only low-Nibble
    add bl,30h          ; convert to ASCII
    cmp bl,39h          ; above 9?
    jna short P2
    add bl,7            ; "A" to "F"
P2: mov [di],bl         ; store ASCII in buffer
    inc di              ; increase target address
    dec cl              ; decrease loop counter
    jnz P1              ; jump if cl is not equal 0 (zeroflag is not set)

    mov dx,OFFSET ASCII ; DOS 1+ WRITE STRING TO STANDARD OUTPUT
    mov ah,9            ; DS:DX->'$'-terminated string
    int 21h             ; maybe redirected under DOS 2+ for output to file
    ret
print_ax endp
end start