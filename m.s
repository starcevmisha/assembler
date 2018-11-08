.include	"macro.s"
.globl	_start

.data
	msg: .ascii	"Hello, Macro!!!\n"
	lmsg = . - msg

.text
_start:
	printf	msg	lmsg
	print_str "Hello, Misha!\n"
	push1	%rax %rbx %rdi
	push2 	"ax, cx, 12"	
	push3	"abcd"
	mov		$1000, %eax
	superdiv 2
	superdiv 8
	superdiv 0
	superdiv 7
	superdiv 5
	ex_it	2
