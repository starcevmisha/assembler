model tiny
.data 
    help_msg    	db "This programm prints ASCII table on the screen", 0Dh, 0Ah, "/m - specify, which mode to use (default 2):", 0Dh, 0Ah, "     0, 1 - 16 colors, 40x25 (25 rows with 40 symbols) with gray\without", 0Dh, 0Ah,"     2, 3 - 16 colors, 80x25 with gray\without", 0Dh, 0Ah, "/p - specify, on which page to print (default 0):", 0Dh, 0Ah, "     0-7 for modes 0 and 1.", 0Dh, 0Ah, "     0-3 for modes 2 and 3.", 0Dh, 0Ah, "/? - this help.", 0Dh, 0Ah, "$"
    SLASH   = '/'
    HELP    = '?'
    MODE    = 'm'
    PAGE    = 'p'
    mode_num		db 00000010b
    page_num		db 0

.code
org 100h
start:

    buffer      db 30 DUP (0)
    mov cl, ds:[0080h]  ; CX: number of bytes to write
    mov di, 81h


args_loop:   
    call read_next_arg
    
    mov bl, 0
	cmp bl, [buffer]
    je prog_start
    
    mov bl, SLASH
	cmp bl, [buffer]
    jne help_message_print

    mov bl, HELP      
	cmp bl, [buffer+1]
    je help_message_print

    mov bl, MODE      
	cmp bl, [buffer+1]
    je mode_choose

    mov bl, PAGE      
	cmp bl, [buffer+1]
    je page_choose

    jmp exit


mode_choose:
    call read_next_arg
    mov bl, [buffer]
    sub bl, 30h
    mov [mode_num], bl
    jmp args_loop
page_choose:
    call read_next_arg
    mov bl, [buffer]
    sub bl, 30h
    mov [mode_num], bl
    jmp args_loop


help_message_print:
    mov dx, offset help_msg
    mov ah, 9
    int 21h
    
exit:
    mov ax,4C00h
    int 21h 


prog_start:
    mov ah, 05h
	mov al, byte ptr page_num
	int 10h

    mov ah, 0
    mov al,byte ptr mode_num ;Первый бит = очистиь экран
    int 10h

    xor dx, dx
    and al, 01111111b
    cmp al,2
    jl small_screen
    mov dl, (80-32)/2
    jmp big_screen
small_screen:
    mov dl, (40-32)/2
big_screen:
    mov dh, (25-16)/2
    mov ah, 2
    int 10h

    mov si, 256 ; наш счетчик цикла
    mov di, 1   ; счетчик строк
    mov al, 0   ; символ
    mov ah, 9   ; номер функции 
    mov cx, 1   ; число повторений
    mov bl, 000000000b ; арибут

main_loop:    
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
    jnz main_loop
    
    mov ax,4C00h
    int 21h 

read_next_arg proc
    ; читает строку из di, пропускает пробелы
    ; и  помещает первое значение после пробелов в buffer
    cld
    
    push di
    push cx
    mov al, 0
    mov di, offset buffer
    xor cx, cx
    mov cx, 30
    rep stosb
    pop cx
    pop di

    mov al, ' '
    repe scasb
    jz stop_loop1

    dec di
    inc cx

    mov si, di
    mov di, offset buffer
    loop1:
    mov al, [si]
    cmp al, 20h
    je stop_loop1
    cmp cl, 0h
    je stop_loop1
    inc si
    
    stosb
    dec cx
    jmp loop1
    stop_loop1:
    mov al, '$'
    stosb
    mov di, si ; возвращаем обратно
    ret
read_next_arg endp

end start