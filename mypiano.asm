model tiny
locals
.data
    ASCII   db "0000 ","$"           ; buffer for ASCII string
    old     dd  0                   ; адрес старого обработчика
    buffer  db, 10 dup(0),0
    buffer_len db 10
    head    db, 0
    tail    db, 0   

.code
org 100h



start:
    call install_09int
    xor ax,ax
loop1:
    mov al, [buffer]
    call print_ax
    mov al, [buffer+1]
    call print_ax
    mov al, [buffer+2]
    call print_ax
    mov al, [buffer+3]
    call print_ax
    mov al, [buffer+4]
    call print_ax
    mov al, [buffer+5]
    call print_ax
    mov al, [buffer+6]
    call print_ax
    mov al, [buffer+7]
    call print_ax
    mov al, [buffer+8]
    call print_ax
    mov al, [buffer+9]
    call print_ax
    mov al, [buffer+10]
    call print_ax

    mov  ah, 02h
mov  dl, 10     ;Get the H character
int  21h
mov  ah, 02h
mov  dl, 13     ;Get the H character
int  21h
xor ax, ax    
    ; call read_from_buffer
    ; cmp al, 0
    ; jz loop1
    
    ; cmp al, 01
    ; je exit
    
    ; call print_ax

    jmp loop1

exit:
    call uninstall_09int
    mov ax,4C00h
    int 21h

write_to_buffer proc ;принимаем в al
    push bx
    mov bx, 0
    
    @@loop:
    cmp [buffer+bx], 0
        jne @@next1
        mov [buffer+bx], al
        jmp @@ret1
    @@next1:
    cmp [buffer+bx], al
        jne @@next2
        call shift_buffer
        jmp @@loop    ; Убрали из массива это число и на новой итерации мы его запишем в конец
    @@next2:
    inc bx
    cmp bl, buffer_len
    jne @@loop

    @@ret1:
    pop bx
    ret
write_to_buffer endp

shift_buffer proc; Номер начиная с которого мы сещаем все символы
    push bx
    push ax
    
    @@loop:
    mov al, [buffer+bx+1]
    mov [buffer+bx], al


    inc bx
    cmp bl, buffer_len
    jne @@loop
    
    pop ax
    pop bx
    ret 
shift_buffer endp


remove_from_buffer proc;
    push bx
    mov bx, 0
    
    and al, 01111111b; скан код нажатой клавиши из отпущенного
    
    @@loop:
    cmp [buffer+bx], al
        jne @@next2
        call shift_buffer
        jmp @@loop    ; Убрали из массива это число
    @@next2:
    inc bx
    cmp bl, buffer_len
    jne @@loop

    @@ret1:
    pop bx
    ret
    
remove_from_buffer endp


int09 proc
    push ax
    in  al,60h
    mov bl ,al
    and bl, 80h
    cmp bl, 0
    jne @@remove
    call write_to_buffer
    jmp @@next
    @@remove:
    call remove_from_buffer
    @@next:
    ;Разрешим дальнейшую работу клавиатуры
    in al,61h ;Введем содержимое порта В
    or al,80h ;Подтвердим прием кода, добавив
    out 61h,al ;бит 80h к содержимому порта В
    and al,7Fh ;Снова разрешим работу клавиатуры.
    out 61h,al ;сбросив в порте В бит 80h .

    ;Пошлем в контроллер прерываний команду EOI
    mov al,20h
    out 20h,al
    pop ax ;Восстановим регистр
    iret ;Выход из прерывания
int09 endp

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

install_09int proc
    mov     ax,  3509h               ; получение адреса старого обработчика
    int     21h                      
    mov     word ptr old,  bx        ; сохранение смещения обработчика
    mov     word ptr old + 2,  es    ; сохранение сегмента обработчика
   
    mov     ax,  2509h               ; установка адреса нашего обработчика
    mov     dx,  offset int09        ; указание смещения нашего обработчика
    int     21h                      ; вызов DOS
    ret
install_09int endp

uninstall_09int proc
    mov dx, word ptr old
	push ds
	push word ptr old + 2
	pop ds
	mov ax, 2509h
	int 21h
	pop ds
	ret
uninstall_09int endp

end start   
