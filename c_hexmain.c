/*
 * String functions for multithreaded client/server calculator program
 * CSF Assignment 2
 * Yuntao Li
 * yli346@jhu.edu
 */
// C implementation of hexdump main function

#include "hexfuncs.h"  // this is the only header file which may be included!

//helper function to print
void printHex(char string_data_buf[], long position, int size){
  char hex_string[9];
  char colonSpace[] = ": ";
  char Space[] = " ";
  char doubleSpace[] = "  ";
  char nextline[] = "\n";
  //format offset and print offset
  hex_format_offset(position, hex_string);
  hex_write_string(hex_string);   
  hex_write_string(colonSpace);
  
  for(int i = 0; i<size; i++){
    char char_hex[3];
    hex_format_byte_as_hex((long)string_data_buf[i], char_hex);
    hex_write_string(char_hex);
    hex_write_string(Space);
  }
  //print space for example byte
  for(int i = size; i<16; i++){
    hex_write_string(doubleSpace);
    hex_write_string(Space);
  }
  
  hex_write_string(Space);

  for(int i = 0; i<size; i++){
    char c[2];
    c[0] = hex_to_printable(string_data_buf[i]);
    c[1] = '\0';
    hex_write_string(c);
  }
  
  hex_write_string(nextline);
}

int main(void) {
  long position = 0;
  char string_data_buf[16];
  int newSize = 0;
  int currSize = 0;
  char currArray[16];
  while((newSize = hex_read(string_data_buf))>0){
    for(int i = 0; i<newSize; i++){
      //put char from read to to correct position
      currArray[(currSize+i)%16] = string_data_buf[i];
      //print if there is 16 chars
      if(currSize+i==15){
	printHex(currArray,position,16);
	position+=16;	
      }
    }
    currSize+=newSize;
    currSize%=16;
  }
  //print the last row
  if(currSize!=0){
    printHex(currArray,position,currSize);
  }
}


