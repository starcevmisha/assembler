.globl	_start

.data
base = 8
number = 0xABC

buff:	.ascii	"                                   \n" 
lbuff = . - buff

.text
_start:
	movq		$buff,	%rdi
	movabsq		$number, %rax
	mov			$base,	%rbx	# на что будем делить

	xorl		%ecx, 	%ecx
loop: # Положим все остатки от деления встек. в %ecx лежит количество в стеке
	xorq		%rdx,	%rdx
	div			%rbx			# частное rax + остаток rdx
	pushq		%rdx			# 
	incl		%ecx
	testq		%rax,	%rax	# в ZF будет 0, если %rax==0
	jnz			loop			# если не ноль


2:
	popq		%rax			#в младшем байте циферка, которую мы должны напечатаь	
	cmpb		$9,		%al
	jbe			3f
	addb		$7,		%al

3:
	mov			%rax, %rax
	addb		$0x30,	%al
	stosb
	
	decl		%ecx
	jnz			2b

	
	mov 	$1, %eax
	mov 	$1, %edi
	mov 	$buff, %rsi
	mov 	$lbuff, %edx
	syscall
	
	mov 	$60, %eax
	mov 	$1, %edi
	syscall
