.data
str1:	.ascii "Hello, string!\n"
lstr = . - str1;
str2:	.fill	lstr, 0
.text
.globl _start
_start:
	mov 	$str1, %rsi
	mov 	$str2, %rdi
	mov		$lstr, %ecx
	
	shl		$3, %ecx #Умнлжаем на 8
	dec 	%ecx
1:
	bt		%ecx,(%rsi)
	jnc 	2f
	bts		%ecx, (%rdi)

2:
	dec		%ecx
	jns		1b 			#Если число меньше 0, то у негог будет знак
	

	mov		$str1, %rsi
	call	print_str
	
	mov		$str2, %rsi
	call	print_str
	
	mov		$60, %eax
	syscall


print_str:
	mov	$1, %eax
	mov	$1, %edi
	mov $lstr,	%edx
	syscall
	ret
