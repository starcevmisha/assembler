model tiny
.data 
    help_msg    	db "This programm prints ASCII table on the screen", 0Dh, 0Ah, "/m - specify, which mode to use (default 2):", 0Dh, 0Ah, "     0, 1 - 16 colors, 40x25 (25 rows with 40 symbols) with gray\without", 0Dh, 0Ah,"     2, 3 - 16 colors, 80x25 with gray\without", 0Dh, 0Ah, "/p - specify, on which page to print (default 0):", 0Dh, 0Ah, "     0-7 for modes 0 and 1.", 0Dh, 0Ah, "     0-3 for modes 2 and 3.", 0Dh, 0Ah, "/? - this help.", 0Dh, 0Ah, "$"
    error_page_mode_msg db "too big page, mode or their combination is incorect", 0Dh, 0Ah, "$"
    CUR_MODE_STR db "Currnet mode = "
    CUR_PAGE_STR db "Currnet page = "
    SLASH   = '/'
    HELP    = '?'
    MODE    = 'm'
    PAGE    = 'p'
    BRIGHT  = 'b'
    mode_num		db 00000010b
    page_num		db 0
    bright_mode     db 1


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
    jne c2
	jmp prog_start
c2:
		
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

    mov bl, BRIGHT     
	cmp bl, [buffer+1]
    je bright_choose

    jmp exit

bright_choose:
    mov [bright_mode], 0
    jmp args_loop

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
    mov [page_num], bl
    jmp args_loop


help_message_print:
    mov dx, offset help_msg
    mov ah, 9
    int 21h
    
exit:
    mov ax,4C00h
    int 21h 
error_page_mode:
    mov dx, offset error_page_mode_msg
    mov ah, 9
    int 21h
    jmp exit

check_page_and_mode:
		cmp mode_num, 7
		je big_mode
        cmp mode_num, 3
        jg big_mode
        cmp mode_num, 1 
        jle check_small
    check_big:
        cmp page_num, 3
        jg error_page_mode
        ret
    check_small:
        cmp page_num, 7
        jg error_page_mode
        ret
	big_mode:
		 cmp page_num, 7
        jg error_page_mode
        ret

prog_start:
    call check_page_and_mode

 ;save display
	mov ah, 0fh   ; AH = number of character columns
	int 10h  	  ; AL = display mode
                  ; BH = active page
	push bx
    push ax ; Сохраняем видео


    mov ah, 05h
	mov al, byte ptr page_num
	int 10h

    mov ah, 0
    mov al,byte ptr mode_num ;Первый бит = очистиь экран
    int 10h

    mov ax, 1003h
    mov bl, [bright_mode]
    int 10h


    push 0
    pop es
    mov dl, es:[044Ah]
    sub dl, 31
    shr dl, 1;dl = (x-31)/2
    mov dh, (25-16)/2

    and al, 01111111b
    cmp al,2

    mov si, 256 ; наш счетчик цикла
    mov di, 1   ; счетчик строк
    mov al, 0   ; символ
    mov ah, 9   ; номер функции 
    mov cx, 1   ; число повторений
    mov bl, 000000000b ; арибут

main_loop:    
    call get_color
    call print_symbol
    inc al
    call print_space_if_need

    test al, 0fh
    jnz check   ; если не кратен 16, то продолжаем печатать строку, иначе
    call new_line
    
check:
    dec si
    jnz main_loop
    
    mov ah, 0
    int 16h

    pop ax
    mov ah, 0
    int 10h

    pop bx 
    mov al, bh
    mov ah, 05h
    int 10h

    mov ax,4C00h
    int 21h

new_line:
    inc dh
    sub dl, 31
    inc di
    ret
print_symbol:; dl - столбец,dh - строка. bl - цвет, al - символ
    push ax
    push bx
    push dx
    push di
    

    mov ah, bl ; помещаем цвет символа
    
    push ax
    xor ax, ax ; в di пишем dh*80*2 + 2*dl
    mov al, dh ; al = dh   
    push dx
        push 0
        pop es
        xor bx, bx
        mov bl, es:[044Ah]
        shl bl, 1
        
        mul bx
    pop dx
    
    mov dh, 0
    shl dl, 1
    add ax, dx
    mov di, ax   
    pop ax
    
    push 0b800h
	pop es  
    mov es:[di],ax
    
    pop di
    pop dx
    pop bx
    pop ax
    inc dl
    ret

print_space_if_need:     
    test al, 0fh ; не печатаем последний символ
    jz skip_last_space   
    push ax
    mov al, 20h
    call print_symbol
    pop ax
    skip_last_space:
    ret
    
get_color:;в bl будет лежать цвет
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
        ret

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