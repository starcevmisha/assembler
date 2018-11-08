.nolist

.macro ex_it	exit_code=0
	mov 		$60, %eax
	mov 		$\exit_code,  %edi
	syscall
.endm

.macro	push1 x1 x2 x3
	push \x1
	push \x2
	push \x3
.endm

.macro printf str len
	mov 		$1, %rax
	mov 		$1, %rdi
	mov 		$\str, %rsi
	mov 		$\len, %rdx
	syscall
.endm

.macro print_str str
.data
	1:	.ascii	"\str"
	_len = . - 1b
.text
	printf  1b	_len
.endm

.macro 	push2 	str
		.irp    reg, \str
			push	%r\reg
		.endr
.endm

.macro 	push3	str
		.irpc	reg, \str
			push	%r&reg&x
		.endr
.endm

.macro 	superdiv		num
		.if \num == 2
				shr 	$1, %eax
		.elseif \num == 4
				shr		$2, %eax
		.elseif \num == 8
				shr		$3, %eax
		.elseif \num == 0
				.error "Нельзя делить на 0!!!"
		.else
				.if \num == 7
					.warning "Не Рекомендуется"
				.endif
				mov		$\num, %ebx
				idiv	%ebx
		.endif
.endm
