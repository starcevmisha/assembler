model tiny
.data
    buffer      db 30 DUP (0)
    intrpt_str 	db "interrupt call", "$"
    func_str   	db "function call", "$"
    no_args     db "No ARGS",10,13, "/h - show help", 10,13, "/u - uninstal TSR program",10,13, "/i - install TSR program",10,13, "$"
    installed_str   db "Resident Already Installed", 10,13,"$"
    SLASH    = '/'
    HELP    = 'h'
    INSTALL_ARG   = 'i'
    UNINSTAL = 'u'

    INT_CODE = 27h
    FUNC_CODE = 31h
    PARAGRAPH_SIZE = 16

.code
ORG 100h

start:
    jmp real_start
    
    flag 	    db 0
    old         dd  0
    old_vector_hello       db "I Am here! Old Vector: ","$",0
    new_vector db "  New Vector: ","$",0
    ASCII       db "0000","$" ; buffer for ASCII string
    loaded      db "LOADED",13,10, "$",0
    
tsr   proc                             ; процедура обработчика прерываний от таймера
        pushf                            ; создание в стеке структуры для IRET
        call    cs:old                   ; вызов старого обработчика прерываний
        rol     dx,8
        push    ds                       ; сохранение модифицируемых регистров
        push    es
	    push    ax
	    push    bx
        push    cx
        push    dx
	    push    di
        push    cs
        pop     ds

        mov al, [flag]
        cmp al, 00
        jne loaded_yet
        inc al
        mov [flag], al
        

        mov dx, offset ds:old_vector_hello
        mov ah, 9
        int 21h

        mov ax, word ptr old+2 ; выводим старый вектор
        call print_ax
        mov  ah, 02h
        mov  dl, ":"     
        int  21h
        mov ax, word ptr old
        call print_ax

        mov dx, offset ds:new_vector ; выводим новый вектор
        mov ah, 9
        int 21h
        mov ax, cs
        call print_ax
        mov  ah, 02h
        mov  dl, ":"     
        int  21h
        mov ax, offset tsr
        call print_ax
        mov  ah, 02h
        mov  dl, 10     
        int  21h



        jmp depop

loaded_yet:
depop:
        pop     di                       ; восстановление модифицируемых регистров
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        pop     es
        pop     ds
        iret   
tsr   endp                             ; конец процедуры обработчика

print_ax proc
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
    ret
print_ax endp

end_tsr:

real_start:
    mov cl, ds:[0080h]  ; CX: number of bytes to write
    mov di, 81h
    
    call read_next_arg

    mov bl, SLASH
	cmp bl, [buffer]
    jne help_message_print

    mov bl, HELP      
	cmp bl, [buffer+1]
    je help_message_print

    mov bl, INSTALL_ARG
	cmp bl, [buffer+1]
    je install

    jmp exit

install:
  
    mov     ax,  352Fh               ; получение адреса старого обработчика
    int     21h                      ; 
    mov     word ptr old,  bx        ; сохранение смещения обработчика
    mov     word ptr old + 2,  es    ; сохранение сегмента обработчика

    mov dx, 00FFh
    xor ax, ax
    int 2fh

    cmp dx, 0FF00h
    je already_installed_print

    mov     ax,  252Fh               ; установка адреса нашего обработчика
    mov     dx,  offset tsr          ; указание смещения нашего обработчика
    int     21h                      ; вызов DOS
   
    mov     ax,  3100h               ; функция DOS завершения резидентной программы
    mov     dx, (end_tsr - start + 10Fh) / 16 + 1 ; определение размера резидентной
                                                ; части программы в параграфах
    int     21h                      ; вызов DOS

    jmp exit

already_installed_print:
    mov dx, offset installed_str
    mov ah, 9
    int 21h
    jmp exit
help_message_print:
    mov dx, offset no_args
    mov ah, 9
    int 21h
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