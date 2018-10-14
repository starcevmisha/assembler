.text
.globl _start
_start:
	mov	$num, %eax



	mov	$16, %ecx
_loop:
	rol	$4, %rax	# ������ ������ � �����
	push	%rax
	push	%rcx
	and	$0xf, %eax	# ����� ��������� 
	movb	dict(%eax), %al	# ����� ������ �� ������ �� ��������
	movb	%al, buf
	
	mov 	$0x1, %rax	# 1 = sys.write	
	mov 	$0x1, %rdi	# 1 = fd (stdout)
	lea 	buf, %rsi	# buffer address
	mov 	$0x1, %rdx	# 1 = bytes count
	syscall

	pop	%rcx
	pop	%rax
	
	dec %ecx	
	jnz _loop

	mov $60, %eax
	mov $0, %edi
	syscall
	
.data
num = 0x27b
dict:	.ascii "0123456789ABCDEF"
buf:	.ascii " "
