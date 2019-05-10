.model tiny
locals
.data
    ASCII   db "0000 ","$"           ; buffer for ASCII string
    buffer_len  db 200
    snake_body  db 10,10, 255 dup(0)
    
    init_length db 4
    next_direction db 3

    directions dw 0100h, 0FF00h, 00FFh, 0001h; down, up, left, right
    
    head        db 0
    tail        db 0

.code
org 100h
start:
    mov ax,0003h
	int	10h
    
    call init_snake; напечать змейку в начале

main:
    call key_press
    
    call print_head
    call update_head_coordinates
    
    call remove_tail
   
    call hide_cursor

    call delay
    jmp main

exit:
    mov dh, 0
    mov dl, 0
    xor bx, bx
    mov ah, 02
    int 10h

    mov ax,4C00h
    int 21h

update_head_coordinates proc
    xor bx,bx
    mov bl, next_direction
    shl bx, 1
    mov bx, [directions+bx]
    call get_head_coordinates   
    call inc_head    
    add cl, bl
    add ch, bh
    call set_head_coordinates
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
    push cx
	mov ah,0
	int 1Ah 
	add dx,3
	mov bx,dx
    repeat:   
	int 1Ah
	cmp dx,bx
	jl repeat
	pop cx
	ret
delay endp

print_head proc
    push ax
    
    xor bx, bx
    mov bl, head
    shl bl, 1
    mov dh, byte ptr [snake_body+bx]; уcтановим столбец
    inc bx
    mov dl, byte ptr [snake_body+bx];Установим строку
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

    xor bx, bx
    mov bl, tail
    shl bl, 1
    mov dh, byte ptr [snake_body+bx]; уcтановим столбец
    inc bx
    mov dl, byte ptr [snake_body+bx];Установим строку
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
    push bx
    xor bx, bx
    mov bl, head
    shl bl, 1
    mov ch, [snake_body+bx];; ch - уоордината x
    inc bl
    mov cl, [snake_body+bx];; cl - координата y
    pop bx
    ret
get_head_coordinates endp

set_head_coordinates proc;; ch - координата x, cl - координата y
    push bx
    xor bx, bx
    mov bl, head
    shl bl, 1
    mov [snake_body+bx], ch
    inc bx
    mov [snake_body+bx], cl
    pop bx
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

key_press proc
    mov ax, 0100h
	int 16h
	jz ret1 			;Без нажатия выходим
	xor ah, ah
	int 16h
    
    ;; ESC
    cmp ah, 01h
    jne @@nxt1
    jmp exit
    @@nxt1:

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


    ret1: 
    ret
key_press endp

inc_head proc
    push bx
    inc head
    mov bl, head
    cmp bl, buffer_len
    jb @@ret1
    mov head, 0
    @@ret1:
    pop bx
    ret
inc_head endp

inc_tail proc
    push bx
    inc tail
    mov bl, tail
    cmp bl, buffer_len
    jb @@ret2
    mov tail, 0
    @@ret2:
    pop bx
    ret
inc_tail endp

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

