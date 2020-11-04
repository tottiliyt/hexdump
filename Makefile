#
# Makefile for CSF Assignment 2
#
# You should not need to change anything in this makefile
#

C_SRCS = c_hexfuncs.c c_hexmain.c hextests.c tctest.c secret_hextests.c
CFLAGS = -g -Og -no-pie -Wall -Wextra -pedantic -std=gnu11

ASM_SRCS = asm_hexfuncs.S asm_hexmain.S
ASMFLAGS = -g -no-pie

LDFLAGS = -no-pie

%.o : %.c
	gcc $(CFLAGS) -c $<

%.o : %.S
	gcc -c $(ASMFLAGS) $*.S -o $*.o

all : c_hextests c_hexdump asm_hextests asm_hexdump

c_hextests : c_hexfuncs.o hextests.o tctest.o
	gcc -o $@ $(LDFLAGS) c_hexfuncs.o hextests.o tctest.o

c_hexdump : c_hexfuncs.o c_hexmain.o
	gcc -o $@ $(LDFLAGS) c_hexfuncs.o c_hexmain.o

asm_hextests : asm_hexfuncs.o hextests.o tctest.o
	gcc -o $@ $(LDFLAGS) asm_hexfuncs.o hextests.o tctest.o

# hexdump program using C main and assembly language functions
casm_hexdump : asm_hexfuncs.o c_hexmain.o
	gcc -o $@ $(LDFLAGS) asm_hexfuncs.o c_hexmain.o

# hexdump program using assembly language main and functions
asm_hexdump : asm_hexfuncs.o asm_hexmain.o
	gcc -o $@ $(LDFLAGS) asm_hexfuncs.o asm_hexmain.o

c_secret_hextests : c_hexfuncs.o secret_hextests.o tctest.o
	gcc -o $@ $(LDFLAGS) c_hexfuncs.o secret_hextests.o tctest.o

asm_secret_hextests : asm_hexfuncs.o secret_hextests.o tctest.o
	gcc -o $@ $(LDFLAGS) asm_hexfuncs.o secret_hextests.o tctest.o

# Use this target to create a zipfile that you can submit to Gradescope
.PHONY: solution.zip
solution.zip :
	rm -f solution.zip
	zip -9r $@ Makefile *.h *.c *.S

clean :
	rm -f *.o c_hextests asm_hextests c_hexdump asm_hexdump casm_hexdump depend.mak solution.zip

depend.mak :
	touch $@

depend :
	gcc -M $(C_SRCS) > depend.mak

include depend.mak
