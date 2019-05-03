model tiny
locals

.data
    bold    dw 3
    width   dw 301
    height  dw 101
    startx  dw 100
    starty  dw 100
    color   db 10
    
    circle_x dw 100
    circle_y dw 100
    circle_rad   db 10

.code
org 100h
start:
    mov     AH,0    ;функция 0 - установка режима
    mov     AL,10h  ;выбор режима 10h
    int     10h     ;обращение к видео-BIOS

    mov cx, startx
    mov dx, starty
    mov al, 10
    call draw_rectangle

    mov al ,6
    call draw_circle

    ; mov     AH,0ch  ;функция ch - изображение точки
    ; mov     BH,0    ;выбор страницы 0
    ; mov cx, 100
    ; mov dx, 100
    ; mov al , 6
    ; int     10h     ;обращение к видео-BIOS

    ; mov cx, 100
    ; mov dx, 200
    ; mov al , 6
    ; int     10h     ;обращение к видео-BIOS

    
    ; mov cx, 400
    ; mov dx, 200
    ; mov al , 6
    ; int     10h     ;обращение к видео-BIOS   
    ;  mov cx, 400
    ; mov dx, 100
    ; mov al , 6
    ; int     10h     ;обращение к видео-BIOS   
    
    ;  mov cx, 150
    ; mov dx, 150
    ; mov al , 15
    ; int     10h     ;обращение к видео-BIOS   





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
