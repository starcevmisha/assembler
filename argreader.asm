model tiny
.data
    buffer db 30 DUP (0)

.code
ORG 100h

start:
    
    mov cl, ds:[0080h]  ; CX: number of bytes to write
    mov di, 81h
    
    call read_next_arg
    call print_buffer

    call read_next_arg
    call print_buffer

exit:
    mov   ax, 4C00h
    int   21h

print_buffer proc
    mov  dx, offset buffer
    mov  ah, 9       
    int  21h

    MOV dl, 10
    MOV ah, 02h
    INT 21h

    MOV dl, 13
    MOV ah, 02h
    INT 21h
    ret
print_buffer endp

read_next_arg proc
    ; читает строку из di, пропускает пробелы
    ; и  помещает первое значение после пробелов в buffer
    cld
    mov al, ' '
    repe scasb
    jz ab 

    dec di
    inc cx

    mov si, di
    mov di, offset buffer
    loop1:
    mov al, [si]
    cmp al, 20h
    je stop_loop1
    cmp cl, 0h
    je stop_loop1
    inc si
    
    stosb
    dec cx
    jmp loop1
    stop_loop1:
    mov al, '$'
    stosb
    mov di, si ; возвращаем обратно
    ret
read_next_arg endp

end start