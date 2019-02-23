model tiny
.data
    buffer db 30 DUP (0)
.code
ORG 100h

start:
    
    jmp main

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
    je ab
    cmp cl, 0h
    je ab
    inc si
    
    stosb
    dec cx
    jmp loop1
ab:
    mov al, '$'
    stosb
    mov di, si ; возвращаем обратно
    ret
    read_next_arg endp

main:
    ; mov ah, 40h         ; DOS 2+ - WRITE - WRITE TO FILE OR DEVICE
    ; mov bx, 1           ; File handle = STDOUT
    ; xor ch, ch
    ; mov cl, ds:[0080h]  ; CX: number of bytes to write
    ; mov dx, 81h         ; DS:DX -> data to write (command line)
    ; int 21h

    mov cl, ds:[0080h]  ; CX: number of bytes to write
    mov di, 81h
    
    call read_next_arg
    call print_buffer

    call read_next_arg
    call print_buffer





exit:
    mov   ax, 4C00h
    int   21h

end start