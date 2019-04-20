model tiny
.data
    ASCII   db "0000 ",10,13,"$"           ; buffer for ASCII string
    old     dd  0                   ; адрес старого обработчика
    buffer  db, 10 dup(0)
    buffer_len db 5
    head    db, 0
    tail    db, 0   

.code
org 100h



start:
    call install_09int
    xor ax,ax
loop1:

    call read_from_buffer
    cmp al, 0
    jz loop1
    
    cmp al, 01
    je exit
    
    call print_ax

    jmp loop1

exit:
    call uninstall_09int
    mov ax,4C00h
    int 21h

write_to_buffer proc ;принимаем в al
    push bx
    xor bx,bx
    mov bl, head
    mov [buffer + bx], al
  
    inc head
    mov bl, head
    cmp bl, buffer_len
    jl ret1
    mov head, 0

    ret1:
    pop bx
    ret
write_to_buffer endp

read_from_buffer proc; отаём в al. Если пусто, то ZF = 1

    mov bl, tail
    cmp head, bl
    je empty

    xor bx,bx
    mov bl, tail
    mov al, [buffer + bx]
    
    inc tail
    mov bl, tail
    cmp bl, buffer_len
    jl ret2
    mov tail, 0
    ret2:
    ret

    empty:
    xor ax,ax
    ret
read_from_buffer endp


int09 proc
    push ax
    in  al,60h
    call write_to_buffer
    
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