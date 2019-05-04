model tiny
locals

.data
    old     dd  0                   ; адрес старого обработчика
    bold    dw 5
    width   dw 301
    height  dw 101
    startx  dw 100
    starty  dw 100
    newx    dw 100
    newy    dw 100
    color   db 11
    
    circle_x dw 100
    circle_y dw 100
    new_circle_x dw 100
    new_circle_y dw 100
    circle_rad   dw 10
    is_exit db 0
    is_repaint db 1

    old_mouse_x dw 0
    old_mouse_y dw 0

.code
org 100h
start:
    mov     AH,0    ;функция 0 - установка режима
    mov     AL,12h  ;выбор режима 10h
    int     10h     ;обращение к видео-BIOS



    mov         ax,0         ; инициализировать мышь
    int         33h
    mov         ax,1         ; показать курсор мыши
    int         33h

    
    
    mov         ax, 000Ch   ; установить обработчик событий мыши
    mov         cx, 001001b ; событие - левая кнопка
    mov         dx, offset mouse_handler
    int         33h

    call repaint
    
    mov         ah,0         ; ожидание нажатия любой клавиши
    int         16h

    jmp exit

mouse_handler proc
    push cx
    push dx
    cmp old_mouse_x, 0
    jne @@next1
    mov old_mouse_x, cx
    @@next1:
    cmp old_mouse_x, 0
    jne @@next2
    mov old_mouse_x, dx
    @@next2:
    cmp ax, 00001b ; перемещение
    je move

    cmp ax, 01000b ;правая кнопка мыши
    je rmb
    jmp ret1
    
    move:
        test bx, 001b ; Нажата левая кнопка
        jnz lmb_move

        call move_circle_if_need
        call repaint
        jmp ret1
    lmb_move:
        call check_coordinates
        jz @@dont_update
        call update_coordinates
        @@dont_update:
        jmp ret1
    rmb:  
        push ax
        mov al, color
        inc al
        and al, 01111b
        mov color, al
        pop ax
        call repaint
    ret1:
        pop dx
        pop cx

        mov old_mouse_x, cx
        mov old_mouse_y, dx
        retf
mouse_handler endp
update_coordinates:

    mov ax, startx;;смещаем прямоугольник
    sub ax, old_mouse_x
    add ax, cx
    mov newx, ax
    
    mov ax, circle_x; смещаем круг
    sub ax, old_mouse_x
    add ax, cx
    mov new_circle_x, ax

    @@next0:
    mov ax, newx
    mov bx, new_circle_x
    sub bx, circle_rad

    cmp ax, bx ; в ax левый край
    jl @@circ_left
        mov ax, bx
    @@circ_left:
        cmp ax, 0
        jge @@next1
        sub newx, ax
        sub new_circle_x, ax
    
    
    @@next1:
    mov ax, newx
    add ax, width

    mov bx, new_circle_x
    add bx, circle_rad

    cmp ax, bx ; в ax правый край
    jg @@circ_right
        mov ax, bx
    @@circ_right:
        cmp ax, 640
        jl @@next2
        sub newx, ax
        add newx, 640
        sub new_circle_x, ax
        add new_circle_x, 640
    
    @@next2:
    
    mov ax, starty
    sub ax, old_mouse_y
    add ax, dx
    mov newy, ax

    mov ax, circle_y
    sub ax, old_mouse_y
    add ax, dx
    mov new_circle_y, ax

    
    mov ax, newy
    mov bx, new_circle_y
    sub bx, circle_rad

    cmp ax, bx ; в ax верхний край
    jl @@circ_up
        mov ax, bx
    @@circ_up:
        cmp ax, 0
        jge @@next3
        sub newy, ax
        sub new_circle_y, ax
    @@next3:

    mov ax, newy
    add ax, height
    mov bx, new_circle_y
    add bx, circle_rad

    cmp ax, bx ; в ax нижний край
    jg @@circ_down
        mov ax, bx
    @@circ_down:
        cmp ax, 480
        jl @@next4
        sub newy, ax
        add newy, 480
        sub new_circle_y, ax
        add new_circle_y, 480
    

    @@next4:

    call repaint

ret
repaint:
    mov         ax,2        ; спрятать
    int         33h


    
    mov al, color
    push ax
    mov color, 0

    mov cx, startx
    mov dx, starty
    call draw_rectangle
    


    mov cx, circle_x
    mov dx, circle_y
    call draw_circle

    pop ax
    mov color, al

    mov cx, newx
    mov dx, newy
    call draw_rectangle

    mov al, color
    xor al, 3
    mov color, al ; поменяем цвет для круга
    
    mov cx,new_circle_x
    mov dx, new_circle_y
    call draw_circle
    
    mov al, color
    xor al, 3
    mov color, al



    mov bx, new_circle_x; положим новвые координаты
    mov circle_x, bx
    mov bx, new_circle_y
    mov circle_y, bx

    mov bx, newx ; положим новвые координаты
    mov startx, bx
    mov bx, newy
    mov starty, bx
    

    mov         ax,1         ; показать курсор мыши
    int         33h

    ret

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
        ; call PlotPixel 
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

; draw_circle proc ;  cx-xЦЕЕНТР, dx-yЦЕНТР
;     xor ax, ax  
;     mov al, circle_rad
    
;     sub cx, ax; Получаю координаты левого верхнего угла
;     sub dx, ax; Получаю координаты левого верхнего угла
    
;     shl ax, 1; получаю диаметр


;     mov si, bold
;     shr si,1
;     add cx, si
;     add dx, si

;     mov si, ax; кладу диаметр

;     @@loop:
;     call draw_horizontal_line
;     dec ax
;     inc dx

;     cmp ax, 0
;     jne @@loop


;     ret
; draw_circle endp

draw_circle proc
    push bp
    mov bp, sp
    push ax   ; x_value [bp - 2]
    push ax   ; y_value [bp - 4]
    push ax   ; decision[bp - 6]

    mov circle_x, cx
    mov circle_y, dx

    mov bx, circle_rad
    mov [bp-6], 0
    sub [bp-6], bx
    mov [bp-2], bx
    mov [bp-4], 0

    @@loop1:
    mov al,color ;colour goes in al
    mov ah,0ch

    mov cx, [bp-2] ;Octonant 1
    add cx, circle_x ;( x_value + circle_x,  y_value + circle_y)
    mov dx, [bp-4]
    add dx, circle_y
    int 10h

    mov cx, [bp-2] ;Octonant 4
    neg cx
    add cx, circle_x ;( -x_value + circle_x,  y_value + circle_y)
    int 10h

    mov cx, [bp-4] ;Octonant 2
    add cx, circle_x ;( y_value + circle_x,  x_value + circle_y)
    mov dx, [bp-2]
    add dx, circle_y
    int 10h

    mov cx, [bp-4] ;Octonant 3
    neg cx
    add cx, circle_x ;( -y_value + circle_x,  x_value + circle_y)
    int 10h

    mov cx, [bp-2] ;Octonant 7
    add cx, circle_x ;( x_value + circle_x,  -y_value + circle_y)
    mov dx, [bp-4]
    neg dx
    add dx, circle_y
    int 10h

    mov cx, [bp-2] ;Octonant 5
    neg cx
    add cx, circle_x ;( -x_value + circle_x,  -y_value + circle_y)
    int 10h

    mov cx, [bp-4] ;Octonant 8
    add cx, circle_x ;( y_value + circle_x,  -x_value + circle_y)
    mov dx, [bp-2]
    neg dx
    add dx, circle_y
    int 10h

    mov cx, [bp-4] ;Octonant 6
    neg cx
    add cx, circle_x ;( -y_value + circle_x,  -x_value + circle_y)
    int 10h

    inc [bp-4]

    condition1:
    cmp [bp-6],0
    jg condition2
    mov cx, [bp-4]
    mov ax, 2
    imul cx
    add cx, 1
    inc cx
    add [bp-6], cx
    mov bx, [bp-4]
    mov dx, [bp-2]
    cmp bx, dx
    jg @@ret1
    jmp @@loop1

    condition2:
    dec [bp-2]
    mov cx, [bp-4]
    sub cx, [bp-2]
    mov ax, 2
    imul cx
    inc cx
    add [bp-6], cx
    mov bx, [bp-4]
    mov dx, [bp-2]
    cmp bx, dx
    jg @@ret1
    jmp @@loop1
    
    @@ret1:
    pop cx
    pop cx
    pop cx
    pop bp
    ret
draw_circle endp

move_circle_if_need proc;cx - mouse x; dx - mouse y
    push ax
    
    mov ax, circle_x
    push ax
    mov ax, circle_y
    push ax

    mov ax, starty
    cmp circle_y, ax
    jne @@next1
        mov ax, circle_x
        sub ax, old_mouse_x
        add ax, cx
        mov new_circle_x, ax
        
        ;если на врехней палке
        ; mov new_circle_x, cx
        mov ax, startx
        cmp new_circle_x, ax
        jg @@next01
        mov new_circle_x, ax; если меньше чем нужно
        @@next01:
        add ax, width
        cmp new_circle_x, ax
        jl @@next1
        mov new_circle_x, ax; если больше чем нужно        
    
    
    @@next1:
    mov ax, new_circle_x
    mov circle_x, ax 

    

    mov ax, startx
    cmp circle_x, ax
    jne @@next2
        mov ax, circle_y
        sub ax, old_mouse_y
        add ax, dx
        mov new_circle_y, ax

        ;левая палка
        mov ax, starty
        cmp new_circle_y, ax
        jg @@next11
        mov new_circle_y, ax
        @@next11:
        add ax, height
        cmp new_circle_y, ax
        jl @@next2
        mov new_circle_y, ax   
    


    @@next2:
    mov ax, new_circle_y
    mov circle_y, ax 

    mov ax, starty
    add ax, height
    cmp circle_y, ax
    jne @@next3
        ;если на нижней палке
        mov ax, circle_x
        sub ax, old_mouse_x
        add ax, cx
        mov new_circle_x, ax
        
        mov ax, startx
        cmp new_circle_x, ax
        jg @@next21
        mov new_circle_x, ax; если меньше чем нужно
        @@next21:
        add ax, width
        cmp new_circle_x, ax
        jl @@next3
        mov new_circle_x, ax; если больше чем нужно  

    @@next3:
    mov ax, new_circle_x
    mov circle_x, ax 
    
    mov ax, startx
    add ax, width
    cmp circle_x, ax
    jne @@next4
        ;левая палка
        mov ax, circle_y
        sub ax, old_mouse_y
        add ax, dx
        mov new_circle_y, ax

        mov ax, starty
        cmp new_circle_y, ax
        jg @@next31
        mov new_circle_y, ax
        @@next31:
        add ax, height
        cmp new_circle_y, ax
        jl @@next4
        mov new_circle_y, ax 
    
    
    @@next4:

    pop ax
    mov circle_y, ax
    pop ax
    mov circle_x, ax
    

    pop ax
    ret
move_circle_if_need endp

check_coordinates proc
    @@check_circle:
        mov ax, circle_x
        sub ax, circle_rad
        cmp old_mouse_x, ax
            jl @@check_rect
        
        mov ax, circle_x
        add ax, circle_rad
        cmp old_mouse_x, ax
            jg @@check_rect
        
        mov ax, circle_y
        sub ax, circle_rad
        cmp old_mouse_y, ax
            jl @@check_rect
        
        mov ax, circle_y
        add ax, circle_rad
        cmp old_mouse_y, ax
            jg @@check_rect
        jmp @@ret_good
    
    @@check_rect:
        mov ax, startx
        cmp old_mouse_x, ax
            jl @@ret_bad

        mov ax, startx
        add ax, width
        cmp old_mouse_x, ax
            jg @@ret_bad
        
        mov ax, starty
        cmp old_mouse_y, ax
            jl @@ret_bad

        mov ax, starty
        add ax, height
        cmp old_mouse_y, ax
            jg @@ret_bad
    
        
        mov ax, startx
        add ax, bold
        cmp old_mouse_x, ax
            jl @@ret_good
        
        mov ax, starty
        add ax, bold
        cmp old_mouse_y, ax
            jl @@ret_good
        
        mov ax, startx
        add ax, width
        sub ax, bold
        cmp old_mouse_x, ax
            jg @@ret_good
        
        mov ax, starty
        add ax, height
        sub ax, bold
        cmp old_mouse_y, ax
            jg @@ret_good


        jmp @@ret_bad
    @@ret_good:
        ret
    @@ret_bad:
        xor ax, ax
        ret
check_coordinates endp



end start
