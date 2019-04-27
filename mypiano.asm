model tiny
locals
.data
    ASCII   db "0000 ","$"           ; buffer for ASCII string
    old     dd  0                   ; адрес старого обработчика
    buffer  db, 10 dup(0),0
    buffer_len db 10
    tail    db -1; индекс последнего элемента
    is_exit db 0
    octave db 0
    freqs  dw 9121,8609,8126,7670,7239,6833,6449,6087,5746,5423,5119,4831,4560,4304,4063,3834,3619,3416,3224,3043,2873,2711,2559,2415,2280,2152,2031,1917,1809,1715,1612,1521,1436,1355,1292,1207

    song db 0,1, 1,1, 2,1, 3,1, 4,1, 5,1, 6,1, 7,3, 8,2, 10,1, 9,1
    is_music db 0
.code
org 100h



start:
    call install_09int
    xor ax,ax
loop1:
    cmp is_exit,0
    jg exit

    cmp is_music, 1
    jne @@next12
    call play_music
    
    
    @@next12:
    xor ax, ax 


    call print_buffer

    cmp tail, 0; Если ничего не нажато
    jl sound_off

    xor bx, bx
    mov bl, tail 
    mov al, [buffer+bx]     ; нажатая клавиша
    sub al, 010h
    mov bl, octave
    call play_note
   


    jmp loop1

play_note proc; al - клавиша, bl - октава
    push cx
    push ax
    push bx

    mov     al, 182         ; Prepare the speaker for the
    out     43h, al         ;  note.
    
    pop cx;октава
    pop ax;клавиша
    
    @@mul:
    cmp cl, 0
    je @@next1
    dec cl
    add al,12
    jmp @@mul

    @@next1:
    xor bx, bx
    mov bl, al
    shl bl,1                ; так как частота у нас двумя байтами
    mov ax, [freqs+bx]      ; частота

    out     42h, al         ; Output low byte.
    mov     al, ah          ; Output high byte.
    out     42h, al 
    in      al, 61h         ; Turn on note (get value from
                                ;  port 61h).
    or      al, 00000011b   ; Set bits 1 and 0.
    out     61h, al         ; Send new value.
    pop cx
    ret
play_note endp
sound_off:
    in      al, 61h         ; Turn off note (get value from port 61h).
    and     al, 11111100b   ; Reset bits 1 and 0.
    out     61h, al         ; Send new value.
    jmp loop1

exit:
    in      al, 61h         ; Turn off note (get value from port 61h).
    and     al, 11111100b   ; Reset bits 1 and 0.
    out     61h, al         ; Send new value.

    call uninstall_09int
    mov ax,4C00h
    int 21h

write_to_buffer proc ;принимаем в al
    push bx
    mov bx, 0
    
    cmp al, 01h
    jne @@next_cmp0
    mov is_exit,1; Если ESC то потом выйдем
    
    @@next_cmp0:
    cmp al, 32h
    jne @@next_cmp1
    mov is_music,1; поиграем музыку
    
    @@next_cmp1:
    cmp al, 02h
    jne @@next_cmp2
    mov octave,0

    @@next_cmp2:
    cmp al, 03h
    jne @@next_cmp3
    mov octave,1

    @@next_cmp3:
    cmp al, 04h
    jne @@1
    mov octave,2
    
    @@1:
    cmp al, 010h ; Только второй ряд с букввми на клавиатуре обрабатываем
    jl @@ret1
    cmp al, 01bh
    jg @@ret1

    @@loop:
    cmp [buffer+bx], 0
        jne @@next1
        mov [buffer+bx], al
        inc tail
        jmp @@ret1
    @@next1:
    cmp [buffer+bx], al
        jne @@next2
        call shift_buffer
        dec tail
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
        dec tail
        jmp @@ret1    ; Убрали из массива это число
    @@next2:
    inc bx
    cmp bl, buffer_len
    jne @@loop

    @@ret1:
    pop bx
    ret
    
remove_from_buffer endp

print_buffer proc
    mov al, tail
    call print_ax
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
    mov al, octave
    call print_ax

    mov  ah, 02h
    mov  dl, 13 
    int  21h


    ret
print_buffer endp

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

play_music proc
    mov cx, 0
    
    xor ax, ax
    xor bx, bx
    
    @@loop:
        mov bx, cx
        shl bx,1
        mov al, [song+bx]
        inc bx
        mov bl, [song+bx]
        call play_note

        mov     ax, 2          ; Pause for duration of note.
    .pause1:
        mov     bx, 65535
    .pause2:
        dec     bx
        jne     .pause2
        dec     ax
        jne     .pause1

        inc cx
        cmp cx,10
    jne @@loop

    mov is_music,0

    ret
play_music endp 

end start   
