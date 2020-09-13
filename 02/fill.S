data:
    .space 40960, 20

_hello:                                 ## @hello
	## .cfi_startproc
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movl	%edi, -4(%rbp)
	movl	-4(%rbp), %esi
	leaq	L_.str(%rip), %rdi
	movb	$0, %al
	callq	_printf
	movl	%eax, -8(%rbp)          ## 4-byte Spill
	addq	$16, %rsp
	popq	%rbp
	retq
_main:                                  ## @main
    ## .cfi_startproc
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$32, %rsp
	movl	%edi, -4(%rbp)
	movq	%rsi, -16(%rbp)
	movl	$6, -20(%rbp)
	movl	-20(%rbp), %edi
	callq	_hello
	xorl	%eax, %eax
	addq	$32, %rsp
	popq	%rbp
	retq
    ## .cfi_endproc

L_.str:                                 ## @.str
	.asciz	"hello world, %d\n"