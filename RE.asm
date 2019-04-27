    model tiny
    .code
    org 100h
_start:
buffer db 7, 10 dup(0)

xor ax, ax
    mov dx, offset buffer
    mov ah, 0ah
    int 21h

    mov ax,4C00h
    int 21h 
end _start