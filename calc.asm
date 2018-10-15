.globl	_start


.data
a=12
b=10
operat = '%'
buff:	.ascii	"                                   \n" 
lbuff = . - buff

.text
_start:
	movq		$buff,	%rdi
	xor 		%rax, %rax	
	movabsq		$a, %rax

	xorl		%ecx, 	%ecx
	
	mov			$operat, %dx
	
	cmp 		$0x2b, 	%dx # (+)
	je 			addition
	cmp 		$0x2d, 	%dx # (-)
	je 			subtraction
	cmp			$0x2a, 	%dx # (*)
	je			multiplication
	cmp			$0x2f, 	%dx # (/)
	je			division
	cmp			$0x25, 	%dx # (%)
	je			modul


subtraction:
	sub			$b, %rax
	jmp			print	
addition:
	add			$b, %rax
	jmp 		print
multiplication:
	imul		$b, %rax
	jmp 		print
division: # целая часть в %rax
	mov			$10,  %rbx
	xorq		%rdx, %rdx
	div			%rbx
	jmp 		print
modul:
	mov			$10,  %rbx
	xorq		%rdx, %rdx
	div			%rbx
	mov			%rdx, %rax
	jmp 		print


	


print:
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
