.globl	_start

.data
.set N, 100
.set OPEN, 2
.set READ, 0
.set O_RDONLY, 0
.set O_WRONLY, 1
.set O_CREATE, 64

filename: .asciz ""
buffer: .skip N
errormsg: .ascii "Что-то не то\n"
lerrormsg = . - errormsg


.text
_start:
get_filename:
	pop 	%rdx 		# argc
	cmp		$4, %rdx
	jne		error		# Если передали не 3 аргумента 
	add 	$8, %rsp

open_read:
	mov 	$OPEN, %rax
	pop		%rdi				# На вершине стека лежит первый аргумент
	mov 	$O_RDONLY, %rsi
	syscall
	
	cmp $0, %rax
	jl error	
	
	mov %rax, %r10
	

open_write:
	mov 	$OPEN, %rax
	pop		%rdi				# На вершине стека лежит первый аргумент
	mov 	$65, %rsi			# O_WRONLY|O_CREATE = 65
	mov		$0777, %rdx
	syscall
	
	cmp $0, %rax
	jl error
	
	mov %rax, %r12

read_sym:	
	pop 	%r15				# Символ с которым будем ксорить	
	mov 	(%r15), %r15

read:
	mov 	$READ, %rax
	mov		%r10, %rdi
	mov 	$buffer, %rsi
	mov		$N, %rdx
	syscall

	cmp 	$0, %rax
	jz 		exit	
	
xor:
	mov 	(%rsi), %cl
	cmp 	$0, %cl # Если закончился ввод
	je 		write
	
	xor 	%r15, (%rsi)	
	inc 	%rsi
	jmp 	xor


write:	
	mov 	$1, %rax
	mov 	%r12, %rdi
	mov 	$buffer, %rsi
	mov 	$N, %rdx
	syscall
	
	jmp read


error:
	mov 	$1, %eax
	mov 	$1, %edi
	mov 	$errormsg, %rsi
	mov 	$lerrormsg, %edx
	syscall

	 
exit:
	mov 		$3, %rax		# Закрываем оба файла	
	mov 		%r10, %rdi
	syscall
		
	mov 		$3, %rax
	mov 		%r11, %rdi
	syscall


	mov 		$60, %rax
	mov 		$0, %rdi
	syscall
