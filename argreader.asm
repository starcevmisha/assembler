model tiny
.data
    buffer      db 30 DUP (0)
    intrpt_str 	db "interrupt call", "$"
    func_str   	db "function call", "$"
    hello       db 'Hello, ASM!',10,13, '$'

    SLASH    = '/'
    FUNCT    = 'f'
    INTRPT   = 'i'

INT_CODE = 27h
FUNC_CODE = 31h
PARAGRAPH_SIZE = 16

.code
ORG 100h

start:
    jmp real_start

resident_start:
    mov  ah, hello   
    int  21h
    ret

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

    mov dx, offset real_start ; Адрес с которотго можно след команду начинать
    int INT_CODE

    jmp exit

func:
    mov  dx, offset func_str
    call print_from_dx
    
    xor ax, ax
	xor dx, dx
	
	mov ax, offset real_start
	mov dl, PARAGRAPH_SIZE
	div dl
	xor dx, dx
	mov dl, al
	cmp ah, 0
	je .cont
	inc dl

	.cont:
	xor ax, ax

    mov al, 0
    mov ah, FUNC_CODE
    int 21h

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