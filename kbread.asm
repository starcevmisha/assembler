model tiny
.data
    ASCII       db "0000","$" ; buffer for ASCII string
.code
org 100h

start:

    mov ah, 0
    int 16h

    cmp ah, 01
    je exit

    call print_ax

    push ax
    mov dl, 20h
    mov ah, 2
    int 21h
    pop ax

    mov dl, al
    mov ah, 2
    int 21h

    mov dl, 10
    mov ah, 2
    int 21h
        


    jmp start

exit:
    mov ax,4C00h
    int 21h



print_ax proc
    push ax
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
    pop ax
    ret
print_ax endp

print_symbol proc



print_symbol endp



end start