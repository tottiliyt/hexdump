/*
 * String functions for multithreaded client/server calculator program
 * CSF Assignment 2
 * Yuntao Li
 * yli346@jhu.edu
 */
	
/* Hexdump main function, assembly language version */
	.section .rodata
	
	sColonSpace: .string ": "
	sSpace: .string " "
	sTripleSpace:.string "   ";
	sNextline: .string "\n";

	.section .text

	.globl main
	
main:
	/*
	varibles and memory allocation
	*%rbp -> [array of 16 byte read from stdin]
	*%rbp+32 ->[array of 32 byte to print to stdout]
	*%rbp+48 ->[array of 16 byte to save offset]
	*rbp+64 ->[array of 8 byte to save format as hex]
	*rbp+72 ->[array of 8 byte to save printable]
	*
	*%r12 -> number of bytes offset
	*%r13 -> actual number read from stdin
	*%r14 -> current number of bytes
	*%r15 -> pointer to buffer
	*/
	
	pushq %rbp	/* save pointer to callee-saved %rbp*/
	pushq %r12	/* save callee-saved registers %r12*/
	pushq %r13	/* save callee-saved registers %r13*/	
	pushq %r14	/* save callee-saved registers %r14*/
	pushq %r15	/* save callee-saved registers %r15*/
	subq $96, %rsp	/* allocate stack space*/
	movq %rsp, %rbp	/* use pointer to point area*/
	movq $0, %r12	/* initialize the read val to zero*/
	movq $0, %r13	/* initialize the curr num to zero*/
	movq $0, %r14 	/*initialize offset value to zero*/
	/*read stdin*/

.LhexreadLoop:
	movq %rbp, %rdi /*used to pass 1st argument to functions*/
	call hex_read	/*read to buffer*/
	movq %rax, %r13 /*save return value(actual read number)*/
	
	/*start copy*/

	movq %rbp, %rdi /*point %rdi(1st arg) to read buffer*/
	movq $0, %rsi /*save the starting position of read buffer at %rsi(2nd arg)*/
	leaq 16(%rbp), %rdx /*point %rdx(3rd arg) to write buffer*/
	movq %r14, %rcx/*save the starting position of write buffer at %rcx(4th arg)*/
	movq %r13, %r8/*save the size of read at %r8(5th arg)*/
	call copy /*copy from read buffer to write buffer*/
	addq %r13, %r14 /*update curr num*/

	cmpq $15,%r14 /* if curr num less or equal to 15*/
	jle .LreadDone/*read more*/

	/*start print*/
	
	movq %r12, %rdi /*pass offset value to %rdi(1st arg)*/
	leaq 48(%rbp), %rsi /*point %rsi(2nd arg) to 9 bytes of buffer region*/
	call hex_format_offset /*write offset to buffer*/
	movq %rsi, %rdi /*pass buffer to %rdi(1st arg)*/
	call hex_write_string /*print*/
	movq $sColonSpace, %rdi /*pass colonspace string to %rdi(1st arg)*/
	call hex_write_string	/*print*/

	leaq 16(%rbp), %rdi /*point write buffer to %rdi(1st arg)*/
	leaq 64(%rbp), %rsi /*point %rsi(2nd arg) to 3 bytes of buffer region*/
	movq $16, %rdx /*save read size to %rdx(3rd arg)*/     
	call print_hex/*print*/

	movq $sSpace, %rdi/*pass space string to %rdi(1st arg)*/
	call hex_write_string /*print*/

	leaq 16(%rbp), %rdi /*point write buffer to %rdi(1st arg)*/
	leaq 72(%rbp), %rsi /*point %rsi(2nd arg) to 2 bytes of buffer region*/
	movq $16, %rdx  /*save read size to %rdx(3rd arg)*/         
	call print_char/*print*/
	
	movq $sNextline, %rdi/*pass nextline string to %rdi(1st arg)*/
	call hex_write_string	/*print*/	

	subq $16, %r14      /*update curr val*/
	addq $16, %r12   /*update offset value*/

	leaq 16(%rbp), %rdi /*point %rdi(1st arg) to write buffer*/
	movq $16, %rsi /*save the starting position of upper write buffer at %rsi(2nd arg)*/
	leaq 16(%rbp), %rdx/*point %rdx(3rd arg) to write buffer*/	
	movq $0, %rcx     /*save the starting position of lower write buffer at %rcx(4th arg)*/ 
	movq %r14, %r8    /*save the size of upper write buffer at %r8(5th arg)*/
	 
	call copy /*adjust the location of left write() file*/

.LreadDone:
	cmpq $0, %r13 /*if read size if not equal to zero*/
	jg .LhexreadLoop /*keep reading*/

	cmpq $0, %r14 /*if there is no more to print*/
	je .LDone /*finish main*/

	/*start print last line*/
	
	movq %r12, %rdi /*pass offset value to %rdi(1st arg)*/
	leaq 48(%rbp), %rsi /*point %rsi(2nd arg) to 9 bytes of buffer region*/
	call hex_format_offset /*write offset to buffer*/
	movq %rsi, %rdi /*pass buffer to %rdi(1st arg)*/
	call hex_write_string /*print*/
	movq $sColonSpace, %rdi /*pass colonspace string to %rdi(1st arg)*/
	call hex_write_string	/*print*/

	leaq 16(%rbp), %rdi /*point write buffer to %rdi(1st arg)*/
	leaq 64(%rbp), %rsi /*point %rsi(2nd arg) to 3 bytes of buffer region*/
	movq %r14, %rdx /*save read size to %rdx(3rd arg)*/     
	call print_hex/*print*/

	movq $16, %rdi /*move 16 to 1st arguement*/
	subq %r14, %rdi /*substract current size from it to get the real size*/
	call printTripleSpace /*print white space*/
	
	movq $sSpace, %rdi/*pass space string to %rdi(1st arg)*/
	call hex_write_string /*print*/

	leaq 16(%rbp), %rdi /*point write buffer to %rdi(1st arg)*/
	leaq 72(%rbp), %rsi /*point %rsi(2nd arg) to 2 bytes of buffer region*/
	movq %r14, %rdx  /*save read size to %rdx(3rd arg)*/         
	call print_char/*print*/
	
	movq $sNextline, %rdi/*pass nextline string to %rdi(1st arg)*/
	call hex_write_string	/*print*/	


.LDone:
	movq $0, %rax	/*return 0*/
	
	addq $96, %rsp	/* allocate stack space*/
	popq %rbp	/* save pointer to callee-saved %rbp*/
	popq %r12	/* save callee-saved registers %r12*/
	popq %r13	/* save callee-saved registers %r13*/	
	popq %r14	/* save callee-saved registers %r14*/

	ret


copy:
	subq $8, %rsp /*align stack*/
	movq $0, %r10 /*set counter*/
	jmp .LcopyCond	/*to to check condition*/

.LcopyLoop:

	movb (%rsi,%rdi, 1), %r11b /*save source to temp %r11*/
	movb %r11b,(%rcx, %rdx, 1) /*save %r11 to dest*/
	incq %r10 /*increase counter*/
	incq %rsi /*move source index up*/
	incq %rcx /*move dest index up*/


.LcopyCond:
	
	cmpq %r8, %r10	/*if counter is smaller than size*/
	jb .LcopyLoop	/*keep copying*/

	addq $8, %rsp	/*realign the stack*/
	ret

print_hex:


	pushq %r12          /* save %r12 */
	pushq %r13          /* save %r13 */
	pushq %r14          /* save %r14 */
	pushq %r15          /* save %r15 */
	subq $8, %rsp       /* align stack pointer */

	movq $0, %r12	/*set counter*/
	movq %rdi, %r13	/*save write buffer as %r13*/
	movq %rsi, %r14 /*save 2 bytes buffer as %r14*/
	movq %rdx, %r15	/*save size to print*/

	jmp .Lprint_hexCond /*check condition*/

.Lprint_hexLoop:
	movzbq (%r12, %r13, 1), %rdi /*pass the char buffer as 1st arg*/
	movq %r14, %rsi /*pass the dest buffer of 3 bytes*/
	call hex_format_byte_as_hex /*convert byte to hex char*/

	movq %r14, %rdi /*pass the hex to 1st arg*/
	call hex_write_string /*print*/

	movq $sSpace, %rdi/*pass space string to %rdi(1st arg)*/
	call hex_write_string /*print*/

	incq %r12 /*increase the counter*/
	jmp .Lprint_hexCond /*check for condition*/
	
	
.Lprint_hexCond:
	
	cmpq %r15, %r12 /*if counter is less than size */
	jb .Lprint_hexLoop /* if true, keep printing hex*/

	addq $8, %rsp       /* restore stack pointer */
	popq %r15           /* restore %r15 */
	popq %r14           /* restore %r14 */
	popq %r13           /* restore %r13 */
	popq %r12           /* restore %r12 */
	ret	
	
print_char:
	pushq %r12          /* save %r12 */
	pushq %r13          /* save %r13 */
	pushq %r14          /* save %r14 */
	pushq %r15          /* save %r15 */
	subq $8, %rsp       /* align stack pointer */

	movq $0, %r12	/*set counter*/
	movq %rdi, %r13	/*save write buffer as %r13*/
	movq %rsi, %r14 /*save 2 bytes buffer as %r14*/
	movq %rdx, %r15	/*save size to print*/

	jmp .Lprint_charCond	/*check condition*/

.Lprint_charLoop:

	movzbq (%r12, %r13, 1), %rdi	/*pass the char array as 1st arg*/
	call hex_to_printable	/*convert hex to printable*/
	movb %al, (%r14)	/*pass the hex to 1st arg*/
	movb $0, 1(%r14)	/*set the null terminator*/
	
	movq %r14, %rdi	/*pass char as 1st arg*/
	call hex_write_string	/*print hex*/

	incq %r12	/*increase the counter*/
	

.Lprint_charCond:

	cmpq %r15, %r12	/*if counter is less than size*/
	jl .Lprint_charLoop	/*if true, keep printing*/

	addq $8, %rsp       /* restore stack pointer */
	popq %r15           /* restore %r15 */
	popq %r14           /* restore %r14 */
	popq %r13           /* restore %r13 */
	popq %r12           /* restore %r12 */
	ret


printTripleSpace:

	pushq %r12	/* save %r12 */
	subq $8, %rsp	/* align the stack*/
	movq %rdi, %r12	/* pass the size to r12*/

.LTripleSpaceLoop:

	movq $sTripleSpace, %rdi/*pass space string to %rdi(1st arg)*/
	call hex_write_string /*print*/
	decq %r12	/*decrease size as counter*/
	
.LTripleSpaceCond:

	cmpq $0, %r12	/*if size counter is greater than zero*/
	jg .LTripleSpaceLoop	/*keep printing space*/
	
	addq $8, %rsp	/*realign the stack*/
	popq %r12	/*restore %r12*/
	ret

/* vim:ft=gas:
 */
