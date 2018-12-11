.global _start 
.data
errormsg: .ascii "Неправильная Запись\n"
lerrormsg = . - errormsg

error_st_msg: .ascii "Мало аргументов на стеке для выполнения функции\n"
lerror_st_msg = . - error_st_msg

warn_st_msg: .ascii "На стеке остались аргументы\nНа вершине:"
lwarn_st_msg = . - warn_st_msg



# %r10 - входня строка
# %r11 - тут парсю аргументы
# %r12 - флаг, число ли?
# %r13 - счетчик стека

.set READ, 0
.set O_RDONLY, 0
.set STDIN, 0
.set N, 100
nl: .byte 0xa 

buffer: .skip N
buffer_in:.skip N

simple_funcs: .asciz "+-*/%" 
funcs_st: .quad _error,_modul, _div, _mult, _minus, _sum 



.text 
_start:
	call read
	mov %rsi, %r10
	mov $0, %r13 

main_loop:
	call read_next_arg
	cmp $0, (%r11) ## Пустой ввод остался. Значит всё уже считали
	je final
	
	
	call check_is_number
	cmp $1, %r12
	je .push_number_in_stack
	
	
.func_handler:
	cmp $2, %r13
	jl error_stack
	dec %r13
	
	lea simple_funcs, %rdi 
	mov (%r11), %al
	mov $5, %rcx
	repne 	scasb
	jnz 1f 
    inc %rcx 
	1:
    movq funcs_st(,%rcx,8), %rbx 
    call *%rbx 
    jmp main_loop 
	
	
	
.push_number_in_stack:
	inc %r13
	call string_to_int
	push %r11
	jmp main_loop		

#####################################################
read_next_arg: # читаем аргумент в %r10 и запихиваем их в %r11
	call reset_buffer_in# Очищаем буффер

	call skip_all_spaces
	mov $0, %rcx
	.loop:
	mov (%r10), %al
	
	cmp $0x20, %al 	# пробел
	je .ret_arg
	cmp $0xA, %al	# \n
	je .ret_arg
	cmp $0, %al		# конец ввода
	je .ret_arg
	
	movb %al, buffer_in(%rcx)
	inc %r10
	inc %rcx
	jmp .loop 
	ret
	
	.ret_arg:
		mov $buffer_in, %r11
		ret

skip_all_spaces: # пропускам пробелы и \n в %r10
	mov (%r10), %al
	cmp $0x20, %al
	je 2f
	cmp $0xA, %al
	je 2f
	ret
	
	2:
		inc %r10
		jmp skip_all_spaces
###############################################################
read:
	mov		$STDIN, %rdi
	mov 	$READ, %rax
	mov 	$buffer, %rsi
	mov		$N, %rdx
	syscall
	ret

#############################################
check_is_number: # Проверим, что аргумент из %r11 - десятичное число, 
	push %r11
	
	mov (%r11), %al
	cmp $45, %al
	jne .check_is_number_loop
	
	inc %r11 # Если Минус, то пропустим его и проверим, что после минуса идут цифры
	mov (%r11), %al
	cmp $0x30, %al
	jl .not_number	
	cmp $0x39, %al
	jg .not_number
	
.check_is_number_loop:	
	mov (%r11), %al
	
	cmp $0, %al
	je .number
	
	cmp $0x30, %al
	jl .not_number
	
	cmp $0x39, %al
	jg .not_number
	
	inc %r11
	
	jmp .check_is_number_loop

.number:
	pop %r11
	mov $1, %r12
	ret
.not_number:
	pop %r11
	mov $0, %r12
	ret

#############################################
string_to_int: # %r11 в число
	xor %rax, %rax 
	xor %rcx, %rcx
	xor %r12, %r12 
	mov $10, %bx # Будем умножать цифры на 10
	
	mov (%r11), %cl
	cmp $45, %cl
	jne .string_to_int_loop
	inc %r12 #  Если число отрицательное то в %r12 будет 1
	inc %r11
	
		
.string_to_int_loop:	
	mov (%r11), %cl
	cmp $0, %cl # Если закончился ввод
	je .return
	
	sub $48, %cl
	mul %rbx
	
	add %rcx, %rax
	
	inc %r11
	
	jmp .string_to_int_loop
	
.return:
	cmp $1,%r12
	jne .positive
	neg %rax
	
	
	.positive:
	mov %rax, %r11
	ret
	
	
#############################################
#Simple Functoins
_modul:
	pop %rcx
	
	pop %rbx
	pop %rax
	xorq	%rdx, %rdx
	cqo
	idiv		%rbx	
	push %rdx
	
	push %rcx
	ret
_div:
	pop %rcx
	
	pop %rbx
	pop %rax
	xorq	%rdx, %rdx
	cqo
	idiv		%rbx	
	push %rax
	
	push %rcx
	ret

_mult:
	pop %rdx
	
	pop %rax
	pop %rbx
	imul	%rax, %rbx
	push %rbx
	
	push %rdx
	ret
_minus:
	pop %rdx
	
	pop %rax
	pop %rbx
	sub	%rax, %rbx
	push %rbx
	
	push %rdx
	ret
_sum:
	pop %rdx
	
	pop %rax
	pop %rbx
	add	%rax, %rbx
	push %rbx
	
	push %rdx
	ret
	
	
#############################################	
write:	
	mov 		$1, %rax
	mov 		$1, %rdi

	syscall
	ret

_nline:
	lea		nl, %rsi 
	mov 	$1, %rdx 
	call 	write 
	ret

_warn:
	lea warn_st_msg, %rsi
	mov $lwarn_st_msg, %rdx
	call write
	ret
#############################################
final:
	cmp $1, %r13
	je .good
	
	call _warn
	
	.good:
	call print
	call _nline
	call exit
	
	



error_stack:
	lea error_st_msg, %rsi
	mov $lerror_st_msg, %rdx
	call write

_error:
	jmp exit




print: ## Печатаем число с вершины стека

	call reset_buffer
	mov $buffer, %rdi
	mov 8(%rsp), %rax
	xorl		%ecx, 	%ecx
	xor			%rbx, %rbx 
	mov			$10, %rbx
	
	cmp $0, %rax
	jge loop
	
	#Если число отрицаельное
	neg %rax
	push % rax
	mov $0x2d, %al
	stosb
	pop %rax
	

loop:
	xorq		%rdx,	%rdx
	div			%rbx
	pushq		%rdx			# 
	incl		%ecx
	testq		%rax,	%rax	# в ZF будет 0, если %rax==0
	jnz			loop			# если не ноль

2:
	popq		%rax
	addb		$0x30,	%al
	stosb
	
	decl		%ecx
	jnz			2b

	mov 		$1, %eax
	mov 		$1, %edi
	mov 		$buffer, %rsi
	mov 		$N, %edx
	syscall
	ret
	
exit:
	mov 	$60, %eax
	mov 	$1, %edi
	syscall
	
##########################################
reset_buffer_in:
	mov		$0, %al
	mov 	$buffer_in, %rdi
	mov		$N, %rcx
	cld	
	rep stosb
	ret
	
reset_buffer:
	mov		$0, %al
	mov 	$buffer, %rdi
	mov		$N, %rcx
	cld	
	rep stosb
	ret
