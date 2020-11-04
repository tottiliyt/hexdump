/*
 * String functions for multithreaded client/server calculator program
 * CSF Assignment 2
 * Yuntao Li
 * yli346@jhu.edu
 */
// C implementation of hexdump functions

#include <unistd.h>  // this is the only system header file you may include!
#include "hexfuncs.h"

// Read up to 16 bytes from standard input into data_buf.
// Returns the number of characters read.

long hex_read(char data_buf[]) {
  //0 is the standard input
  return read(0,data_buf,16);
}



// Write given nul-terminated string to standard output.
void hex_write_string(const char s[]){
  int count = 0;
  //keep write to stdout if nul-terminator is not met
  while(s[count]!='\0'&&write(1,&s[count],1)>0){
    count++;
  }
}

// Format a long value as an offset string consisting of exactly 8
// hex digits.  The formatted offset is stored in sbuf, which must
// have enough room for a string of length 8.
void hex_format_offset(long offset, char sbuf[]){
  unsigned long mask = 0x0000000FUL;
  unsigned long newOffset = (unsigned long)offset;
  for(int i = 7; i>=0; i--){
    unsigned long byte = newOffset & mask;
    //if byte is a number
    if(byte<=9){
      sbuf[i] = '0' + byte;
    }
    // if byte is a letter
    else if(byte>=10){
      sbuf[i] = byte-10+'a';
    }
    //move the mask
    newOffset = newOffset>>4;
  }
  //fill nul-terminator to complete a string
  sbuf[8] = '\0';

}

// Format a byte value (in the range 0-255) as string consisting
// of two hex digits.  The string is stored in sbuf.
void hex_format_byte_as_hex(long byteval, char sbuf[]){
  unsigned long mask = 0x0000000FUL;
  unsigned long newbyteval = (unsigned long)byteval;
  for(int i = 1; i>=0; i--){
    long byte = newbyteval & mask;
    //if the byte is a digit
    if(byte>=0&&byte<=9){
      sbuf[i] = '0' + byte;
    }
    //if the byte is a letter
    else if(byte>=10){
      sbuf[i] = byte-10+'a';
    }
    //right shit 4 bits 
    newbyteval = newbyteval>>4;
  }
  //fill nul-terminator to complete a string
  sbuf[2] = '\0';
}

// Convert a byte value (in the range 0-255) to a printable character
// value.  If byteval is already a printable character, it is returned
// unmodified.  If byteval is not a printable character, then the
// ASCII code for '.' should be returned.
long hex_to_printable(long byteval){
  // a byte is non-printable if less than 32 or greater than 126
  if(byteval<32||byteval>126){
    return 0x2EL;
  }
  return byteval;
}
