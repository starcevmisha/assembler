.model tiny
locals
.data
    ASCII   db "0000 ","$"           ; buffer for ASCII string
    buffer_len  dw 1000

    
    init_length db 4
    next_direction db 3
    head        dw 0
    tail        dw 0
    snake_body  dw 10,60h, 2000 dup('*')
    directions dw 0100h, 0FF00h, 00FFh, 0001h; down, up, left, right

    speed db 2

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

key_press proc
    mov ax, 0100h
	int 16h
	jz ret1 			;Без нажатия выходим
	xor ah, ah
	int 16h
    
    ;; ESC
    cmp ah, 01h
    je @@exit
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

    ;; minus
    cmp ah, 0Ch
    jne @@nxt6
    cmp speed, 6
    jg @@nxt6
    inc speed
    jmp ret1
    @@nxt6:

    ;; plus
    cmp ah, 0Dh
    jne @@nxt7
    cmp speed, 1
    jl @@nxt7
    dec speed
    jmp ret1
    @@nxt7:

 
    ret1: 
    ret
key_press endp

inc_head proc
    push bx
    inc head
    mov bx, head
    cmp bx, buffer_len
    jb @@ret1
    mov head, 0
    @@ret1:
    pop bx
    ret
inc_head endp

inc_tail proc
    push bx
    inc tail
    mov bx, tail
    cmp bx, buffer_len
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

