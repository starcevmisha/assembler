.globl _start

.data
.set N, 100
.set OPEN, 2
.set READ, 0
.set O_RDONLY, 0

errormsg: .asciz "Что-то не то\n"
lerrormsg = . - errormsg
filename: .asciz "1.txt"
char: .asciz "hello"
charl = .-char
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
	call read_block
	mov $buffer, %rdi

first_char_loop:
	
	push %rdi
	call length_rdi
	cmp $0, %rcx
	je read
	pop %rdi
	movb char, %al	
	
	cld
	repne   scasb
	je found

not_found:
	jmp read
found:
	push %rdi #чтобы сохранить на стек и использовать потом
	 
	call deep_search
	pop %r15
	
		
	cmp $0, %r15
	jl first_char_loop
	
	
	push %rdi #чтобы не потерять

	push %r15
	xor %rdi, %rdi
	call print_int
	pop %rdi	
	jmp first_char_loop
	



########################
deep_search:
	mov		$buffer, %rsi 
	mov 	%rdi, %r12
	sub		$buffer, %r12 # индекс начала подстроки

	pop %r10
	pop	%rdi
	mov $char, %r8
	inc %r8
	mov %rdi, %r9
	
_loop:
	mov (%r8), %al # берем первые байт
	xor %bl, %bl
	cmp %al, %bl
	je _success
	
	mov (%rdi), %bl #Если блок кончился
	cmp $0, %bl
	jne _next
	call read_block
	mov %rsi, %rdi
	xor %r14, %r14
	mov $1, %r14 #Флаг показывающий, что перешагули на границе блоков
	jmp _loop
		
	_next:
	inc %r8
	inc	%rdi
	cmp %al, %bl
	je _loop
	
	push $-1 #не нашли
	push %rcx
	ret
_success:
	neg %r14
	add %r13, %r14
	xor %rax, %rax ##Считаем правильно индекс с учетом блоков
	mov $N, %rax
	imul %r14, %rax
	add %rax, %r12
	
	push %r12 # 
	push %r10
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
read_block:
	inc %r13
	pop %rbx

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
	push %rbx
	xor %rbx, %rbx
	ret

###############################
length_rdi:
	xor		%eax, %eax
	xor		%ecx, %ecx
	dec 	%ecx
	repne scasb  # идет по строке из %rdx и сравнивает по байтно с %al, где у нас лежит 0
	neg		%ecx # в ecx будет лежать -1 -(длина строки)
	dec 	%ecx
	dec %ecx
	ret
#####################3
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

