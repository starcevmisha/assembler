.globl	_start


.data
a=12
b=10
operat = '+'
buff:	.ascii	"                                   \n" 
lbuff = . - buff

errormsg: .ascii "Мало аргументов: надо знак и два числа\n"
lerrormsg = . - errormsg

.text
_start:
	movq		$buff,	%rdi
	xor 		%rax, %rax	
	movabsq		$a, %rax

	pop %rdx 		# argc
	cmp $4, %rdx
	jne error

	add $8, %rsp 	# пропускаем argc и arg[0]
	pop %rdx
	mov (%rdx),%rdx # помещаем первый аргумент

	
bp:
	
	#mov			$operat, %dx
	
	cmp 		$0x2b, 	%dx # (+)
	je 			addition
	cmp 		$0x2d, 	%dx # (-)
	je 			subtraction
	cmp			$0x2a, 	%dx # (*)
	je			multiplication
	cmp			$0x78, 	%dx # (x)
	je			multiplication
	cmp			$0x2f, 	%dx # (/)
	je			division
	cmp			$0x25, 	%dx # (%)
	je			modul
	
	jmp error

addition:
b1:
	call	read_args 
	add		%r10, %rax
	jmp		print
subtraction:
	call	read_args 
	sub		%r10, %rax
	jmp		print	

multiplication:
	call	read_args 
	imul		%r10, %rax
	jmp 		print
division: # целая часть в %rax
	call	read_args 
	mov		%r10,  %rbx
	xorq	%rdx, %rdx
	div		%rbx
	jmp 	print
modul:
	call	read_args 
	mov		%r10,  %rbx
	xorq	%rdx, %rdx
	div		%rbx
	mov		%rdx, %rax
	jmp 	print

error:
	mov 		$1, %eax
	mov 		$1, %edi
	mov 		$errormsg, %rsi
	mov 		$lerrormsg, %edx
	syscall
	jmp 		exit
	
char_to_int:
	xor %rax, %rax 
	xor %rcx, %rcx 
	mov $10, %bx # Будем умножать цифры на 10
	
.loop:	
	mov (%rsi), %cl
	cmp $0, %cl # Если закончился ввод
	je .return
	
	sub $48, %cl
	mul %bx
	
	add %cx, %ax
	
	inc %rsi
	
	jmp .loop
	
.return:
	ret
	

	 

read_args:
	pop %r12 # Запоинаем стек
	pop 	%rsi
	call	char_to_int
	mov		%rax, %r10 # Почему сохраняем не в #rdx? Потому что 
	pop 	%rsi
	call	char_to_int
	xchg %rax,%r10
	push %r12
	ret



print: # Дальше выводим из стека
	xorl		%ecx, 	%ecx
	xor			%rbx, %rbx 
	mov			$10, %rbx
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
	mov 		$buff, %rsi
	mov 		$lbuff, %edx
	syscall

exit:	
	mov 		$60, %eax
	mov 		$1, %edi
	syscall
