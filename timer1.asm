    model tiny
    .code
    org 100h
_start:
buffer db 7, 9 dup(0)

    mov dx, offset buffer
    mov ah, 0ah
    int 21h

ret
end _start