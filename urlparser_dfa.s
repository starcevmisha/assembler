.data 
.set SYS_WRITE, 1 
.set SYS_EXIT, 60 
.set STDOUT, 1 
.set LEN, 100 

buf: .skip LEN 
count: .byte 0 

protstr: .ascii "Протокол: " 
protstrl =. - protstr
hoststr: .ascii "Хост: " 
hoststrl =. - hoststr
urlpathstr: .ascii "URL-путь: " 
urlpathstrl =. - urlpathstr


nl: .byte 0xa 

dictn: .quad 4 

protocol: .asciz "ab:/" 
protocolst: .quad  _st3, _st3, _st2, _st1,_st1 # В обратном порядке

colon: .asciz "/" 
colonst: .quad _st4, _st5 #_st5 - считать слэш

slash1: .asciz "/" 
slash1st: .quad _st4, _st6 #_st6 - считать слэш

slash2: .asciz "ab." 
slash2st: .quad _st4, _st7,_st7, _st7 

address: .asciz "ab./"
addressst: .quad _st3, _st8, _st1, _st1, _st1

path: .asciz "ab./"
pathst: .quad _st9, _st1, _st1, _st1, _st1




.text 
.global _start 
_start: 
	mov		$protocolst, %r8
	mov		16(%rsp), %rsi 
	lea 	protocol, %rdi 
	movq 	dictn, %rcx 


_loop: 
	lodsb 
	push 	%rsi 
	push 	%rdi 

	repne 	scasb 
	jnz 	1f 
	inc 	%rcx 

1: 
	movq 	(%r8,%rcx,8), %rbx 
	call 	*%rbx 
	pop 	%rdi 
	pop 	%rsi 
	jmp 	_loop 

_exit:
	mov 	$SYS_EXIT, %rax 
	mov 	$0, %rdi 
	syscall 

_write:
	mov 	$SYS_WRITE, %rax 
	mov 	$STDOUT, %rdi 
	syscall
	ret
	 
_nline:
	lea		nl, %rsi 
	mov 	$1, %rdx 
	call 	_write 
	ret 


_st1: #читаем буквы из протокола
	xor		%rdx, %rdx 
	movb 	count, %dl 
	movb 	%al, buf(%rdx) 
	inc 	%dl 
	movb 	%dl, count 
	
	movq 	dictn, %rcx 	
	ret 

_st7: //читаем буквы из адресса
	pop %r10
	pop 	%rdi
	lea 	address, %rdi
	push %rdi
	push %r10
	
	mov 	$addressst, %r8
	mov		$4, %rcx
	call 	_st1
	ret

_st2: #читаем двоеточие после протокола и выводим протокол
	pop %r10
	lea 	protstr, %rsi 
	mov 	$protstrl, %rdx 
	call 	_write
	
	lea 	buf, %rsi 
	mov 	$LEN, %rdx 
	call 	_write 
	call 	_nline 
	
	call reset_buffer

	pop 	%rdi
	lea 	colon, %rdi
	push 	%rdi
	mov 	$colonst, %r8
	mov		$1, %rcx
	push %r10
	ret  

_st3:  #читаем слэш Значит был не протокол а адресс
	lea 	hoststr, %rsi 
	mov 	$hoststrl, %rdx 
	call 	_write

	lea 	buf, %rsi 
	mov 	$LEN, %rdx 
	call 	_write 
	call 	_nline
	
	call reset_buffer
 

	
	pop 	%r10
	pop 	%rdi
	lea 	path, %rdi
	push 	%rdi
	push 	%r10
	
	mov 	$pathst, %r8
	mov		$4, %rcx

	ret  

_st4://Если левый символ
	jmp 	_exit
	
_st5: //
	pop %r10
	pop 	%rdi
	lea 	slash1, %rdi
	push %rdi
	push %r10
	
	mov 	$slash1st, %r8
	mov		$1, %rcx
	ret


_st6:
	pop %r10
	pop 	%rdi
	lea 	slash2, %rdi
	push %rdi
	push %r10
	
	mov 	$slash2st, %r8
	mov		$3, %rcx
	ret
	
_st8: # адресс закончился, перходим к path
	lea 	hoststr, %rsi 
	mov 	$hoststrl, %rdx 
	call 	_write
	lea 	buf, %rsi 
	mov 	$LEN, %rdx 
	call 	_write 
	call 	_nline
	
	call reset_buffer
 
	
	pop 	%r10
	pop 	%rdi
	lea 	path, %rdi
	push 	%rdi
	push 	%r10
	
	mov 	$pathst, %r8
	mov		$4, %rcx
	ret

_st9: #url кончился
	lea 	urlpathstr, %rsi 
	mov 	$urlpathstrl, %rdx 
	call 	_write
	
	lea 	buf, %rsi 
	mov 	$LEN, %rdx 
	call 	_write 
	call 	_nline 
	call reset_buffer

	
	jmp _exit

	
reset_buffer:
	movb	$0, count
	mov		$0, %al
	mov 	$buf, %rdi
	mov		$LEN, %rcx
	cld	
	rep stosb
	ret


	

