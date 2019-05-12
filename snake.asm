.model tiny
.386
locals
.data
    ASCII   db "0000 ","$"           ; buffer for ASCII string
    buffer_len  = 10
   
    init_length db 4
    next_direction db 3

    snake_body  dw 20*256+20, 2000 dup('*')
    directions dw 0100h, 0FF00h, 00FFh, 0001h; down, up, left, right

    wall_type db 0
    ;; Слева стена - убийца, справа стена - прыгун, снизу телепорт, сверху зависит от типа


    head        dw 0
    tail        dw 0
    snake_trav  dw 1

    speed dw 7

.code
org 100h
start:
    mov ax,0006h
	int	10h
    
    call init_snake; напечать змейку в начале
    call draw_walls

main:
    mov dh, 1
    mov dl, 1
    xor bx, bx
    mov ah, 02
    int 10h
    mov ax, head
    call print_ax

    mov dh, 2
    mov dl, 1
    xor bx, bx
    mov ah, 02
    int 10h
    mov ax, tail
    call print_ax

    ; mov si, [head]
    ; shl si, 1


    ; mov dh, 2
    ; mov dl, 2
    ; xor bx, bx
    ; mov ah, 02
    ; int 10h
    ; mov ax, snake_body[si]
    ; call print_ax
    ; mov dh, 0
    ; mov dl, 0
    ; xor bx, bx
    ; mov ah, 02
    ; int 10h
    ; mov ax, speed
    ; call print_ax
    
    
    call key_press
    
    call print_head
    call update_head_coordinates    ;; Обновляем координаты с учетом стен
   
    @@next:
    call hide_cursor

    call delay
    jmp main
GAME_OVER:
exit:
    mov dh, 0
    mov dl, 0
    xor bx, bx
    mov ah, 02
    int 10h

    mov ax,0003h
	int	10h

    mov ax,4C00h
    int 21h

update_head_coordinates proc
    xor bx,bx
    mov bl, next_direction
    shl bx, 1
    mov bx, [directions+bx]
    call get_head_coordinates   
        
    add cl, bl
    add ch, bh
    ; call inc_head
    ; call set_head_coordinates

    ;; ПРОВЕРИМ НОВЫЕ КООРДИНАТЫ НА СТЕНЫ И САМОПЕРЕСЕЧЕНИЕ.
    mov dh, ch
    mov dl, cl
    xor bx, bx
    mov ah, 02
    int 10h

    mov ah, 08h ; Прочитать символ
    int 10h
    
    @@portal:
        cmp al, 'O'
        jne @@death
        cmp ch, 0   ;;Если портал в верхней стене, то перемещаемся вниз
        jne @@left
            mov ch, 22
            jmp @@portal_next1
        @@left:
            mov cl, 0
        @@portal_next1:
        ; call set_head_coordinates
        jmp @@update
         
    
    @@death:
        cmp al, '#'
        jne @@spring
        jmp GAME_OVER
    
    @@spring:
        cmp al, 'Z'
        jne @@selfcross
        call revert_snake
    
        ; mov dh, ch
        ; mov dl, cl
        ; xor bx, bx
        ; mov ah, 02
        ; mov al, 'Z'
        ; int 10h

        jmp @@ret
    
    @@selfcross:
        cmp al, '*'
        jne @@update

    @@update:
        call inc_head
        call set_head_coordinates
        call remove_tail
    @@ret:
        ret
update_head_coordinates endp


hide_cursor proc
    mov dh, 80
    mov dl, 25
    xor bx, bx
    mov ah, 02
    int 10h
    ret
hide_cursor endp

delay proc
    push ax bx
        mov     ax, speed         ; Pause for duration of note.
    @@pause1:
        mov     bx, 32767
    @@pause2:
        dec     bx
        jne     @@pause2
        dec     ax
        jne     @@pause1
    pop bx ax
	ret
delay endp

print_head proc
    push ax
    
    mov si, [head]
    shl si, 1

    mov dx, snake_body[si]

    xor bx, bx
    mov ah, 02
    int 10h

    mov cx,1;напечатаем символ
	mov ax,0A2Ah
	int 10h
    
    pop ax
    ret
print_head endp

print_tail proc
    push ax
    
    mov si, [tail]
    shl si, 1

    mov dx, snake_body[si]

    xor bx, bx
    mov ah, 02
    int 10h

    mov cx,1;напечатаем символ
	mov ax,0A20h
	int 10h
    
    pop ax
    ret
print_tail endp

get_head_coordinates proc;; ch - координата x, cl - координата y
    mov si, [head]
    shl si, 1
    mov cx, snake_body[si]

    ret
get_head_coordinates endp

set_head_coordinates proc;; ch - координата x, cl - координата y
    mov si, [head]
    shl si, 1

    mov snake_body[si], cx
    
    ret
set_head_coordinates endp


init_snake proc
    mov al, init_length
    @@loop2: 
    
    call print_head
    call get_head_coordinates   
    inc head    
    add cl, 1
    call set_head_coordinates
    dec al
    jnz @@loop2

    ret
init_snake endp

draw_walls proc

    ;; Верхняя стена - телепорт
    mov dh, 0
    mov dl, 0
    xor bx, bx
    mov ah, 02
    int 10h

    mov ah, 0Ah
    mov al, 'O'
    mov bh, 0
    mov cx, 80
    int 10h

    ;; нижняя стена - прыгун
    mov dh, 23
    mov dl, 0
    xor bx, bx
    mov ah, 02
    int 10h

    mov ah, 0Ah
    mov al, 'Z'
    mov bh, 0
    mov cx, 80
    int 10h

    ;; левая стена - убийца
    mov dh, 1
    mov dl, 0
    xor bx, bx

    mov al, '#'
    push 22
    @@left_loop:
        mov cx, 1
        mov ah, 02
        int 10h

        mov ah, 0Ah
        int 10h


        int 10h
        inc dh
        pop cx 
        dec cx
        push cx
        cmp cx, 0
        jg @@left_loop
    pop cx

    ret
draw_walls endp

key_press proc
    mov ax, 0100h
	int 16h
	jz ret1 			;Без нажатия выходим
	xor ah, ah
	int 16h
    
    ;; ESC
    cmp ah, 01h
    je exit

    ;; down 
    cmp ah, 50h
    jne @@nxt2
    cmp next_direction, 1
    je @@nxt2
    mov next_direction, 0
    jmp ret1
    @@nxt2:

    ;; up
    cmp ah, 48h
    jne @@nxt3
    cmp next_direction, 0
    je @@nxt3
    mov next_direction, 1
    jmp ret1
    @@nxt3:

    ;; left
    cmp ah, 4Bh
    jne @@nxt4
    cmp next_direction, 3
    je @@nxt4
    mov next_direction, 2
    jmp ret1
    @@nxt4:

    ;; right
    cmp ah, 4Dh
    jne @@nxt5
    cmp next_direction, 2
    je @@nxt5
    mov next_direction, 3
    jmp ret1
    @@nxt5:

    ;; minus
    cmp ah, 0Ch
    jne @@nxt6
    cmp speed, 9
    jg @@nxt6
    inc speed
    jmp ret1
    @@nxt6:

    ;; plus
    cmp ah, 0Dh
    jne @@nxt7
    cmp speed, 1
    jle @@nxt7
    dec speed
    jmp ret1
    @@nxt7:
   
 
    ret1: 
    ret
key_press endp

inc_head proc
    push bx
    
    mov bx, head
    add bx, snake_trav
    mov head, bx

    
    cmp bx, buffer_len
    jl @@next1
    mov head, 0
    
    @@next1:
    cmp bx, 0
    jge @@ret1
    mov head, buffer_len
    dec head

    @@ret1:
    pop bx
    ret
inc_head endp

inc_tail proc
    push bx

    mov bx, tail
    add bx, snake_trav
    mov tail, bx
    

    
    cmp bx, buffer_len
    jl @@next1
    mov tail, 0
    
    @@next1:
    cmp bx, 0
    jge @@ret1
    mov tail, buffer_len 
    dec tail


    @@ret1:
    pop bx
    ret
inc_tail endp

revert_snake proc
    push bx cx
    
    mov bx, tail
    mov cx, head
    mov tail, cx
    mov head, bx
    mov next_direction, 1   
    pop cx bx
    neg snake_trav
    
    ret
revert_snake endp

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

remove_tail proc
    call print_tail
    call inc_tail
    ret
remove_tail endp

end start

