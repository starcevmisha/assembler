.globl _start

.data
.set N, 100
.set OPEN, 2
.set READ, 0
.set O_RDONLY, 0

errormsg: .asciz "Что-то не то\n"
lerrormsg = . - errormsg
filename: .asciz "1.txt"
char: .asciz "world"
buffer: .skip N

.text
_start:
	mov 	$OPEN, %rax
	mov		$filename, %rdi
	mov 	$O_RDONLY, %rsi
	syscall
	
	mov		%rax, %rdi
	mov 	$READ, %rax
	mov 	$buffer, %rsi
	mov		$N, %rdx
	syscall	
	
	
	cmp 	$0, %rax
	jl 		error


first_char_loop:
	mov %eax, %ecx
	xor %rax, %rax
	movb (char), %al
	lea	buffer, %rdi
	cld
	repne   scasb
#	sub $buffer, %rdi
	jnz error

deep_search:
	mov $char, %r10
	inc %r10
	mov %rdi, %r11
	
_loop:
	xor %rdx, %rdx
	cmp	(%r10), %rdx	#Если искомое слово закончилось, то значит мы нашли его полность. Выведем символ
	je error
	mov (%r10), %al # берем первые байт
	mov (%r11), %bl # и сравниваем их
	
	
	inc %r10
	inc	%r11
	cmp %al, %bl
	je _loop
	
	


exit:	
	mov 		$60, %rax
	mov 		$0, %rdi
	syscall

error:
	mov 	$1, %eax
	mov 	$1, %edi
	mov 	$errormsg, %rsi
	mov 	$lerrormsg, %edx
	syscall
	jmp exit
