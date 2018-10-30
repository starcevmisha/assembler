.globl _start
.text
_start:
	mov	$12345, %eax
	mov $12345,	%ebx
	xor %edx,	%edx
	
	mov	$63, %ecx

1:
	shl	$1, %rdx	
	bt %rcx, %rax
	jnc	2f
	inc %rdx

2:
	bt %rcx, %rbx
	jnc	3f
	inc %rdx
3:
	dec %al
	jns 1b
	
	mov $60, %eax
	syscall
