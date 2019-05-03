model tiny
locals

.data
old     dd  0                   ; адрес старого обработчика
    bold    dw 3
    width   dw 301
    height  dw 101
    startx  dw 100
    starty  dw 100
    newx    dw 100
    newy    dw 100
    color   db 1
    
    circle_x dw 100
    circle_y dw 100
    new_circle_x dw 100
    new_circle_y dw 100
    circle_rad   db 10
    is_exit db 0
    is_repaint db 1

.code
org 100h
start:
    mov     AH,0    ;функция 0 - установка режима
    mov     AL,10h  ;выбор режима 10h
    int     10h     ;обращение к видео-BIOS


    mov         ax,0         ; инициализировать мышь
    int         33h
    mov         ax,1         ; показать курсор мыши
    int         33h
    
    mov         ax, 000Ch   ; установить обработчик событий мыши
    mov         cx, 001000b ; событие - левая кнопка
    mov         dx, offset mouse_handler
    int         33h
    
    call repaint
    
    mov         ah,0         ; ожидание нажатия любой клавиши
    int         16h

    jmp exit

mouse_handler proc
    ; test ax, 00001b ; перемещение
    ; je move

    cmp ax, 01000b ;правая кнопка мыши
    je rmb
    jmp ret1
    ; move:
    ;     jmp ret1
    ;     ; mov new_circle_x, cx
    ;     ; mov new_circle_y, dx
    ;     ; call repaint

    lmb_move:
    rmb:  
        push ax
        mov al, color
        inc al
        and al, 01111b
        mov color, al
        pop ax
        call repaint
    ret1:
        retf
mouse_handler endp


repaint:
    mov         ax,2        ; спрятать
    int         33h


    
    mov cx, startx
    mov dx, starty
    call draw_rectangle

    mov cx, startx
    mov dx, starty
    call draw_circle

    ; mov color, 15
    
    ; mov cx, startx
    ; mov dx, starty
    ; call draw_rectangle
    ; mov cx, startx
    ; mov dx, starty
    ; call draw_circle

    ; pop ax
    ; mov color, al
    
    ; mov cx, startx
    ; mov dx, starty
    ; call draw_rectangle
    
    ; mov cx, new_circle_x
    ; mov dx, new_circle_y
    ; mov al, color
    ; xor al, 3
    ; mov color, al
    ; call draw_circle

    ; mov bx, new_circle_x
    ; mov circle_x, bx
    ; mov bx, new_circle_y
    ; mov circle_y, bx

    mov         ax,1         ; показать курсор мыши
    int         33h
    
    ret
; repaint_rectangle:
;     mov cx, startx
;     mov dx, starty
;     call draw_rectangle
;     ret

; repaint_circle:


;     mov cx, new_circle_x
;     mov dx, new_circle_y
;     call draw_circle

;     mov bx, new_circle_x
;     mov circle_x, bx
;     mov bx, new_circle_y
;     mov circle_y, bx

;     ret

exit:
    mov         ax,000Ch
    mov         cx,0000h     ; удалить обработчик событий мыши
    int         33h
    mov         ax,3         ; текстовый режим
    int         10h
    mov ax,4C00h
    int 21h

draw_horizontal_line proc; cx - x, dx  -y, si - длина, al-цвет
    push ax
    push dx
    push cx
    push si

    mov ah,0ch  ;функция ch - изображение точки
    mov al, color
    mov bh,0    ;выбор страницы 0
    @@loop:   
        int     10h     ;обращение к видео-BIOS   
        inc cx
        dec si

        cmp si,0 
        jne @@loop

    pop si
    pop cx
    pop dx
    pop ax
    ret
draw_horizontal_line endp

draw_vertical_line proc; cx - x, dx  -y, si - длина, al-цвет
    push ax
    push cx
    push dx
    push si
    
    mov al, color
    mov ah, 0ch  ;функция ch - изображение точки
    mov bh, 0    ;выбор страницы 0
    @@loop:
        int     10h     ;обращение к видео-BIOS   
        inc dx
        dec si

        cmp si,0 
        jne @@loop
    
    pop si
    pop dx
    pop cx
    pop ax
    ret
draw_vertical_line endp

draw_rectangle proc; cx-x, dx-y, al-цвет
    
    mov ax, bold    
    mov si, width
    @@loop1:
    call draw_horizontal_line
    inc dx
    dec ax
    cmp ax, 0
    jne @@loop1
    sub dx, bold

    mov ax, bold
    mov si, height
    @@loop2:
    call draw_vertical_line
    inc cx
    dec ax
    cmp ax, 0
    jne @@loop2
    sub cx, bold


    add dx, height
    sub dx, bold
    
    mov ax, bold    
    mov si, width
    @@loop3:
    call draw_horizontal_line
    inc dx
    dec ax
    cmp ax, 0
    jne @@loop3


    
    sub dx, height
    add cx, width
    sub cx, bold
    
    mov ax, bold    
    mov si,height
    @@loop4:
    call draw_vertical_line
    inc cx
    dec ax
    cmp ax, 0
    jne @@loop4
    sub dx, bold


 
    ret
draw_rectangle endp

draw_circle proc
    mov al, color
    xor al, 3
    mov color, al
    
    xor ax, ax  
    
    mov al, circle_rad
    shl ax, 1
    

    
    mov cx, circle_x
    sub cl, circle_rad
    
    mov dx, circle_y
    sub dl, circle_rad

    mov si, bold
    shr si,1
    add cx, si
    add dx, si


        mov si, ax



    @@loop:
    call draw_horizontal_line
    dec ax
    inc dx

    cmp ax, 0
    jne @@loop

    mov al, color
    xor al, 3
    mov color, al

    ret
draw_circle endp


end start
