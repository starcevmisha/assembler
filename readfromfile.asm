.globl	_start

.data
.set N, 1
.set OPEN, 2
.set READ, 0
.set O_RDONLY, 0

filename: .asciz "1.txt"
buffer: .skip N

.text
_start:
open:
	mov 	$OPEN, %rax
	mov 	$filename, %rdi
	mov 	$O_RDONLY, %rsi
	syscall
	
	mov %rax, %r10

read:
	mov		%r10, %rdi
	mov 	$READ, %rax
	mov 	$buffer, %rsi
	mov		$N, %rdx
	syscall

	cmp $0, %rax
	jz exit	

write:	
	mov 		$1, %rax
	mov 		$1, %rdi
	mov 		$buffer, %rsi
	mov 		$N, %rdx
	syscall
	
	jmp read

	 
exit:	
	mov 		$60, %rax
	mov 		$0, %rdi
	syscall
