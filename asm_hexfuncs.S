/*
 * String functions for multithreaded client/server calculator program
 * CSF Assignment 2
 * Yuntao Li
 * yli346@jhu.edu
 */
/* Assembly language implementation of hexdump functions */

	.section .rodata
	/* TODO: add read-only data such as strings here */

	.section .text
	
	.globl hex_read
	.globl hex_write_string
	.globl hex_to_printable
	.globl hex_format_byte_as_hex
	.globl hex_format_offset
	.globl to_hex
	
hex_read:	/*Read up to 16 bytes from standard input into data_buf. Returns the number of characters read.*/
	subq $8,%rsp 	/*align the stack*/

	movq %rdi,%rsi  /*save the input buffer as the second argument*/
 	movq $0,%rdi	/*save 0(stdin) as the first argument*/
	movq $16,%rdx	/*save 16(bytes) as the third argument*/
	call read	/*call read() function*/

	addq $8,%rsp 	/*align the stack*/
	
	ret 		/*return*/

hex_write_string:	/*Write given nul-terminated string to standard output.*/
	pushq %r12	/* save callee-saved registers %r12*/
	subq $8,%rsp 	/*align the stack*/
	movq $0, %r12 /* set counter to 0 */
.LcountLoop:
	cmpb $0, (%rdi,%r12,1) /* compare rdi with nul-terminator */
	je .LcountDone /* if equal, jump to done*/
	inc %r12 /* count++ */
	jmp .LcountLoop /* loop again*/
.LcountDone:
	movq %rdi, %rsi /* save char *buf as second parameter */
	movq $1, %rdi /* save the dest to the first parameter*/
	movq %r12, %rdx /* save the counter to third paramter*/
	call write
	
	addq $8,%rsp 	/*align the stack*/
	popq %r12	/* restore callee-saved registers %r12*/
	ret 		/*return*/

	
	
hex_format_byte_as_hex: /* Format a byte value (in the range 0-255) as string consisting of two hex digits.  The string is stored in sbuf.*/

	pushq %r12	/*callee-saved registers r12*/
	pushq %r13	/*callee-saved registers r13*/
	pushq %r14	/*callee-saved registers r14*/
	subq $8, %rsp	/*align stack*/

	movq %rdi, %r14 /*save long input at r8*/
	movq %rsi, %r13 /*save buffer at r13*/
	movq $1, %r10	/*set counter*/
	movq $0x0000000F, %r11 /*set mask*/
	
.LhexLoop:

	movq %r14, %r12 /*load long byte to r12*/
	andq %r11, %r12 /*compute mask&long and save to r12*/
	movq %r12, %rdi /*save r12 to rdi as parameter*/
	call to_hex /*convert to hex char*/
	movb %al, (%r13,%r10,1) /*save to buffer*/
	
	decq %r10 /*move the pointer*/
	cmpq $-1, %r10 /*if r10 is less than zero*/
	je .LhexDone /*we finish the loop*/

	sarq $4, %r14 /*bit shift mask to right for 4 bit*/
	
	jmp .LhexLoop /*if dones't finish the loop, loop again*/
	
.LhexDone:

	movb $0, 2(%r13) /*set the nul-terminator*/
	addq $8, %rsp	/*align stack*/
	popq %r14	/*Copies the value stored at r14*/
	popq %r13	/*Copies the value stored at r13*/
	popq %r12	/*Copies the value stored at r12*/
		
	ret

//convert a hex number to it's corresponding character	
to_hex:
	subq $8, %rsp	/*align stack*/
	cmpq $10, %rdi /*if larger than 10*/
	jae .Lalpha /*we should use alphabetic to express*/
	addq $48, %rdi /*if less, add '0'*/
	jmp .Lout /*go to number output*/

.Lalpha:
	addq $87, %rdi /*add 'a'*/
	
.Lout:
	movq %rdi, %rax /*save to return register*/
	addq $8, %rsp	/*align stack*/
	ret

hex_to_printable:/*Convert a byte value (in the range 0-255) to a printable character value.  If byteval is already a printable character, it is returned unmodified.  If byteval is not a printable character, then the ASCII code for '.' should be returned.*/
	subq $8, %rsp	/*align stack*/

	cmpq $32, %rdi /*if less than 32*/
	jl .isNonPrintable /*it's a non printable*/

	cmpq $126, %rdi /*if more than 126*/
	jg .isNonPrintable /*it's a non printable*/

	movq %rdi,%rax /*save reselt to return*/
	addq $8, %rsp /*align stack*/
	ret 
	
.isNonPrintable:
	movq $46, %rax /*output'.' if non-printable*/

	addq $8, %rsp	/*align stack*/
	ret

hex_format_offset: /* Format a long value as an offset string consisting of exactly 8 hex digits.  The formatted offset is stored in sbuf, which must have enough room for a string of length 8.*/
	pushq %r12	/*callee-saved registers 12*/
	pushq %r13	/*callee-saved registers 13*/
	pushq %r14	/*callee-saved registers 14*/
	subq $8, %rsp	/*align stack*/

	movq %rdi, %r14 /*save long input at r8*/
	movq %rsi, %r13 /*save buffer at r13*/
	movq $7, %r10	/*set counter*/
	movq $0x0000000F, %r11 /*set mask*/
	
.LoffsetLoop:

	movq %r14, %r12 /*load long byte to r12*/
	andq %r11, %r12 /*compute mask&long and save to r12*/
	movq %r12, %rdi /*save r12 to rdi as parameter*/
	call to_hex /*convert to hex char*/
	movb %al, (%r13,%r10,1) /*save to buffer*/
	
	
	decq %r10	/*move the pointer*/
	cmpq $-1, %r10	/*if r10 is less than zero*/
	je .LoffsetDone /*we finish the loop*/

	sarq $4, %r14 /*bit shift mask to right for 4 bit*/
	
	jmp .LoffsetLoop /*if dones't finish the loop, loop again*/
.LoffsetDone:

	movb $0, 8(%r13)/*set the nul-terminator*/
	addq $8, %rsp	/*align stack*/
	popq %r14	/*Copies the value stored at r13*/
	popq %r13	/*Copies the value stored at r13*/
	popq %r12	/*Copies the value stored at r12*/
	
	ret
