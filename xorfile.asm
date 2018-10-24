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

.text
_start:
get_filename:
	pop 	%rdx 		# argc

	
	add 	$8, %rsp
open_read:
	mov 	$OPEN, %rax
	pop		%rdi				# На вершине стека лежит первый аргумент
	mov 	$O_RDONLY, %rsi
	syscall
	
	mov %rax, %r10

open_write:
	mov 	$OPEN, %rax
	pop		%rdi				# На вершине стека лежит первый аргумент
	mov 	$65, %rsi			# O_WRONLY|O_CREATE = 65
	mov		$0777, %rdx
	syscall

	mov %rax, %r12
	

read:
	mov 	$READ, %rax
	mov		%r10, %rdi
	mov 	$buffer, %rsi
	mov		$N, %rdx
	syscall

	cmp $0, %rax
	jz exit	



write:	
	mov 		$1, %rax
	mov 		%r12, %rdi
	mov 		$buffer, %rsi
	mov 		$N, %rdx
	syscall
	
	jmp read



error:
	 
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
