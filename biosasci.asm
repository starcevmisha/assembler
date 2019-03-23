model tiny
.code
org 100h

start:
    mov ah, 0
    mov al, 00000011b ;Первый бит = очистиь экран
    int 10h

    xor dx, dx
    mov dl, (80-32)/2
    mov dh, (25-16)/2
    mov ah, 2
    int 10h

    mov si, 256 ; наш счетчик цикла
    mov di, 1   ; счетчик строк
    mov al, 0   ; символ
    mov ah, 9   ; номер функции 
    mov cx, 1   ; число повторений
    mov bl, 000000000b ; арибут

loop1:    
    mov bl, 000001111b
    cmp di, 1
    jne next1
        push dx
        mov bl, 00111111b;
        and dl, 00011110b; берем 4 бита из номера строки 000xxxx0
        ror dl, 1        ; 0000xxxx
        or dl, 011110000b; остальные биты заполняем 1. Получаем 1111xxxx
        and bl, dl 
        pop dx
        
        push dx ; поменяем фон
        and dl, 00001110b  
        xor dx, 00001100b
        rol dl, 3          
        or dl, 010001111b  
        and bl, dl 
        pop dx

next1:        
    cmp di, 3
    jne next2
        push dx
        mov bl, 001111111b
        and dl, 00001110b   ; берем 3 бита из номера строки 0000xxx0
        rol dl, 3           ; 0xxx0000
        or dl, 010001111b   ; 1xxx1111
        and bl, dl 
        pop dx
next2:
    cmp di, 16
    jne next3
        mov bl, 010011100b
next3:
    int 10h ; выводим символ
    
    push ax
    mov ah, 2
    inc dl
    int 10h ; сдвигаем на один символ
    
    
    inc al
    test al, 0fh ; не печатаем последний символ
    jz skip_last_space
    mov ax, 0920h
	int 10h ; напечатать пробел
    mov ah, 2
    inc dl
    int 10h ; сдвигаем на один символ
skip_last_space:
    pop ax
    
    inc al
    test al, 0fh
    jnz check   ; если не кратен 16, то продолжаем печатать строку, иначе

    push ax
    mov ah, 2
    inc dh
    sub dl, 31
    int 10h
    inc di

    pop ax
check:
    dec si
    jnz loop1

    mov ax,4C00h
    int 21h 
    
end start