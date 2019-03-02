model tiny



.code
ORG 100h

start:
    has_run 	db 0
    
    buffer      db 30 DUP (0)
    intrpt_str 	db "interrupt call", "$"
    func_str   	db "function call", "$"
    

    SLASH    = '/'
    FUNCT    = 'f'
    INTRPT   = 'i'

    INT_CODE = 27h
    FUNC_CODE = 31h
    PARAGRAPH_SIZE = 16
    old     dd  0
    hello       db "HELLO ASM!", "$",0
    jmp real_start

tsr   proc                             ; процедура обработчика прерываний от таймера
                pushf                            ; создание в стеке структуры для IRET
        call    cs:old                   ; вызов старого обработчика прерываний
        push    ds                       ; сохранение модифицируемых регистров
        push    es
	    push    ax
	    push    bx
        push    cx
        push    dx
	    push    di
        push    cs
        pop     ds

        
        mov dx, offset ds:hello
        mov ah, 9
        int 21h


        pop     di                       ; восстановление модифицируемых регистров
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        pop     es
        pop     ds
        iret   
tsr   endp                             ; конец процедуры обработчика
end_tsr:

real_start:
    mov cl, ds:[0080h]  ; CX: number of bytes to write
    mov di, 81h
    
    call read_next_arg

    mov bl, SLASH
	cmp bl, [buffer]
    jne exit

    mov bl, INTRPT      
	cmp bl, [buffer+1]
    je interrupt

    mov bl, FUNCT
	cmp bl, [buffer+1]
    je func


interrupt:
    mov  dx, offset intrpt_str
    call print_from_dx


    mov     ax,  352fh               
    int     21h                     
    mov     word ptr old,  bx        ; сохранение смещения обработчика
    mov     word ptr old + 2,  es    ; сохранение сегмента обработчика
    
    mov     ax,  252fh               ; установка адреса нашего обработчика
    mov     dx,  offset tsr     ; указание смещения нашего обработчика
    int     21h                      ; вызов DOS


    mov dx, offset real_start + 10fh        ; Адрес с которотго можно след команду начинать
    int INT_CODE

    jmp exit

func:
    mov  dx, offset func_str
    call print_from_dx
    
    mov     ax,  352Fh               ; получение адреса старого обработчика
    int     21h                      ; прерываний от таймера
    mov     word ptr old,  bx        ; сохранение смещения обработчика
    mov     word ptr old + 2,  es    ; сохранение сегмента обработчика
    
    mov     ax,  252Fh               ; установка адреса нашего обработчика
    mov     dx,  offset tsr        ; указание смещения нашего обработчика
    int     21h                      ; вызов DOS
   
    mov     ax,  3100h               ; функция DOS завершения резидентной программы
    mov     dx, (end_tsr - start + 10Fh) / 16 ; определение размера резидентной
                                                ; части программы в параграфах
    int     21h                      ; вызов DOS

    jmp exit

exit:
    mov   ax, 4C00h
    int   21h

print_buffer proc
    mov  dx, offset buffer
    call print_from_dx
    ret
print_buffer endp

print_from_dx proc
    mov  ah, 9       
    int  21h

    MOV dl, 10
    MOV ah, 02h
    INT 21h

    MOV dl, 13
    MOV ah, 02h
    INT 21h
    ret
print_from_dx endp

read_next_arg proc
    ; читает строку из di, пропускает пробелы
    ; и  помещает первое значение после пробелов в buffer
    cld
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