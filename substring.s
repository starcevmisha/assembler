.globl _start

.data
.set N, 5
.set OPEN, 2
.set READ, 0
.set O_RDONLY, 0

errormsg: .asciz "Что-то не то\n"
lerrormsg = . - errormsg
filename: .asciz "1.txt"
char: .asciz "hello"
buffer: .skip N+1

print_buf: .asciz "                                  \n"
lprint_buf = .-print_buf



.text
_start:
	mov $-1, %r13
	mov 	$OPEN, %rax
	mov		$filename, %rdi
	mov 	$O_RDONLY, %rsi
	syscall
	push 	%rax

read:
	xor %rax, %rax
	mov		$buffer, %rdi
	mov   	$N, %rcx
	rep   	stosb

	inc %r13
	pop %rax
	push %rax
	mov		%rax, %rdi
	mov 	$READ, %rax
	mov 	$buffer, %rsi
	mov		$N, %rdx
	syscall	
		
	cmp 	$0, %rax
	je 		exit
	mov %rax, %r14
	

	mov $0, %r15
	xor %rsi, %rsi
	lea	buffer, %rdi
first_char_loop:
	
	mov $N, %rcx
	cmp $0, %r15
	jg _next
	mov $2, %r15 #смещение если не нашли
	_next:
	sub %r15, %rcx
	xor %rax, %rax
	
	mov $char, %rbx
	add %r9, %rbx # смещаем если нашли на границе блока
	mov (%rbx), %al
	xor %rbx, %rbx
	
	cld
	repne   scasb
	je found

not_found:
	jmp read
found:
	push %rdi #чтобы сохранить на стек и использовать потом
	 
	call deep_search
	pop %r15
	
	cmp $0, %r9
	jg read # Если начало совпало и блок кончился то читаем след
		

	cmp $0, %r15
	jl first_char_loop
	
	xor %rax, %rax ##Считаем правильно индекс с учетом блоков
	mov $N, %rax
	imul %r13, %rax
	add %rax, %r15
	
	push %rdi #чтобы не потерять
	push %r15
	call print_int
	pop %rdi
	jmp first_char_loop
	



########################
deep_search:
	pop %rcx
	pop	%rdi
	mov $char, %r8
	inc %r8
	mov %rdi, %r9
	
_loop:
	mov (%r8), %al # берем первые байт
	xor %bl, %bl
	cmp %al, %bl
	je _success
	
	mov (%r9), %bl # и сравниваем их
	cmp $0, %bl
	je _save_return
	
	inc %r8
	inc	%r9
	cmp %al, %bl
	je _loop
	
	push $-1 #не нашли
	push %rcx
	ret
_success:
	xor %r9, %r9
	mov 	%rdi, %r11
	sub		$buffer, %r11
	push %r11 # 
	push %rcx
	ret
	
_save_return: ##НАшли совпадения начала, но входня строка консилась
	sub %rdi, %r9
	inc %r9
	
	push $-1
	push %rcx
	ret
#######################	
print_int:
	pop %r10
	pop %rax
	
	xorl		%ecx, 	%ecx
	xor			%rbx, %rbx 
	mov			$10, %rbx
	movq		$print_buf,	%rdi

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
	b2:
	mov 		$print_buf, %rsi
	mov 		$lprint_buf, %edx
	push %r10
	syscall
	
_end:	
	ret



###############################

error:
	mov 	$1, %eax
	mov 	$1, %edi
	mov 	$errormsg, %rsi
	mov 	$lerrormsg, %edx
	syscall
exit:	
	mov 		$60, %rax
	mov 		$0, %rdi
	syscall

