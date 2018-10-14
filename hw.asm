.globl	_start

base_number		= 16
digit_in_group  = 2

.data
numm:	.ascii	"                              \n" 
lnumm = . - numm

.text
_start:
	movabsq		$12345678901234567890,	%rax
	xorl		%ecx, 	%ecx
	movq		$base_number,	%rbx
	
loop:
	xorq		%rdx,	%rdx
	div			%rbx   			#������� b + ������� d
	pushq		%rdx
	incl		%ecx
	testq		%rax,	%rax		
	jnz			loop			#���� �� ����
	
	movq		$numm,	%rdi
2:
	popq		%rax			#� ������� ����� �������, ������� �� ������ ���������
	
	cmpb		$9,		%al
	jbe			3f
	addb		$7,		%al
	

3:		
	addb		$0x30,	%al		#����������� � ����������\��������??
	stosb

	movq		%rcx,	%rax
	xorq		%rdx,	%rdx
	movl		$digit_in_group,		%ebx
	div 		%rbx
	#testb		%dl,	%dl
	cmp			$1,		%dl
	jnz 		3f
	

	movb		$0x20,	%al		#�������� ������ ������ 3 �������
	stosb

3:
	decl		%ecx
	jnz			2b

	mov $1, %eax
	mov $1, %edi
	mov $numm, %rsi
	mov $lnumm, %edx
	syscall
	
	mov $60, %eax
	mov $1, %edi
	syscall
