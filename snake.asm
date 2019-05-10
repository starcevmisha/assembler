.model tiny
locals
.data
 ASCII   db "0000 ","$"           ; buffer for ASCII string
    buffer_len  db 10
    snake_body  db 0,50, 100 dup(0)
    
    init_length db 4
    
    head        db 0
    tail        db 0
.code
org 100h
start:
    mov ax,0003h
	int	10h
    
    call init_snake; напечать змейку в начале

main:
    mov dh, 1
    mov dl, 1
    xor bx, bx
    mov ah, 02
    int 10h
    xor ax, ax
    mov al, head

    call print_ax

    mov al, tail

    call print_ax


    call key_press
    
    call print_head
    call get_head_coordinates   
    call inc_head    
    add cl, 1
    call set_head_coordinates

    call print_tail
    call inc_tail


    call delay
    jmp main

exit:
    mov ax,4C00h
    int 21h


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

get_head_coordinates proc;; ch - уоордината x, cl - координата y
    push bx
    mov bl, head
    shl bl, 1
    mov ch, [snake_body+bx];; ch - уоордината x
    inc bl
    mov cl, [snake_body+bx];; cl - координата y
    pop bx
    ret
get_head_coordinates endp

set_head_coordinates proc;; ch - уоордината x, cl - координата y
    push bx
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
    cmp ah, 01h
    jne @@nxt1
    jmp exit
    @@nxt1:
    ret1: 
    ret
key_press endp

inc_head proc
    inc head
    mov bl, head
    cmp bl, buffer_len
    jl @@ret1
    mov head, 0
    @@ret1:
    ret
inc_head endp

inc_tail proc
    inc tail
    mov bl, tail
    cmp bl, buffer_len
    jl @@ret2
    mov tail, 0
    @@ret2:
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

end start

