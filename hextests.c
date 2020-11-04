/*
 * String functions for multithreaded client/server calculator program
 * CSF Assignment 2
 * Yuntao Li
 * yli346@jhu.edu
 */
// Unit tests for hex functions
// These tests should work for both your C implementations and your
// assembly language implementations

#include <stdio.h>
#include <stdlib.h>
#include "tctest.h"
#include "hexfuncs.h"

// test fixture object
typedef struct {
  char test_data_1[16];
  char multipleOf16[16];
  char nonprintable[16];
  char empty[16];
  char large[100];
} TestObjs;

// setup function (to create the test fixture)
TestObjs *setup(void) {
  TestObjs *objs = malloc(sizeof(TestObjs));
  strcpy(objs->test_data_1, "Hello, world!\n");
  strcpy(objs->multipleOf16, "abcdefghABCDEFG");
  strcpy(objs->nonprintable, "\n\n\n\n\n\n\n\n");
  strcpy(objs->empty, "");
  strcpy(objs->large, "Welcome to GNU Emacs, one component of the GNU/Linux operating system.");
  return objs;
}

// cleanup function (to destroy the test fixture)
void cleanup(TestObjs *objs) {
  free(objs);
}

// Prototypes for test functions
void testFormatOffset(TestObjs *objs);
void testFormatByteAsHex(TestObjs *objs);
void testHexToPrintable(TestObjs *objs);

int main(int argc, char **argv) {
  if (argc > 1) {
    tctest_testname_to_execute = argv[1];
  }

  TEST_INIT();

  TEST(testFormatOffset);
  TEST(testFormatByteAsHex);
  TEST(testHexToPrintable);

  TEST_FINI();

  return 0;
}

void testFormatOffset(TestObjs *objs) {
  (void) objs; // suppress warning about unused parameter
  char buf[16];
  //multiple of 16
  hex_format_offset(0L, buf);
  ASSERT(0 == strcmp(buf, "00000000"));
  hex_format_offset(16L, buf);
  ASSERT(0 == strcmp(buf, "00000010"));
  hex_format_offset(1616L, buf);
  ASSERT(0 == strcmp(buf, "00000650"));
  hex_format_offset(3200L, buf);
  ASSERT(0 == strcmp(buf, "00000c80"));
  // not multiple of 16
  hex_format_offset(1L, buf);
  ASSERT(0 == strcmp(buf, "00000001"));
  hex_format_offset(100L, buf);
  ASSERT(0 == strcmp(buf, "00000064"));
  hex_format_offset(10000L, buf);
  ASSERT(0 == strcmp(buf, "00002710"));
  hex_format_offset(1000000, buf);
  ASSERT(0 == strcmp(buf, "000f4240"));
  //large value
  hex_format_offset(100000000, buf);
  ASSERT(0 == strcmp(buf, "05f5e100"));
}

void testFormatByteAsHex(TestObjs *objs) {
  char buf[16];
  //"hello\n"
  hex_format_byte_as_hex(objs->test_data_1[0], buf);
  ASSERT(0 == strcmp(buf, "48")); //H
  hex_format_byte_as_hex(objs->test_data_1[1], buf);
  ASSERT(0 == strcmp(buf, "65")); //e
  hex_format_byte_as_hex(objs->test_data_1[2], buf);
  ASSERT(0 == strcmp(buf, "6c")); //l
  hex_format_byte_as_hex(objs->test_data_1[3], buf);
  ASSERT(0 == strcmp(buf, "6c")); //l
  hex_format_byte_as_hex(objs->test_data_1[4], buf);
  ASSERT(0 == strcmp(buf, "6f")); //o
  hex_format_byte_as_hex(objs->test_data_1[13], buf);
  ASSERT(0 == strcmp(buf, "0a")); //\n
  hex_format_byte_as_hex(objs->test_data_1[14], buf);
  ASSERT(0 == strcmp(buf, "00")); //\0
  hex_format_byte_as_hex(objs->multipleOf16[0], buf);
  ASSERT(0 == strcmp(buf, "61")); //a
  hex_format_byte_as_hex(objs->multipleOf16[1], buf);
  ASSERT(0 == strcmp(buf, "62")); //b
  hex_format_byte_as_hex(objs->multipleOf16[3], buf);
  ASSERT(0 == strcmp(buf, "64")); //d
  hex_format_byte_as_hex(objs->multipleOf16[8], buf);
  ASSERT(0 == strcmp(buf, "41")); //A
  hex_format_byte_as_hex(objs->multipleOf16[15], buf);
  ASSERT(0 == strcmp(buf, "00")); //\0
  hex_format_byte_as_hex(objs->nonprintable[0], buf);
  ASSERT(0 == strcmp(buf, "0a")); //\n
  hex_format_byte_as_hex(objs->nonprintable[1], buf);
  ASSERT(0 == strcmp(buf, "0a"));  //\n
  hex_format_byte_as_hex(objs->empty[0], buf);
  ASSERT(0 == strcmp(buf, "00")); //\n
  hex_format_byte_as_hex(objs->large[50], buf);
  ASSERT(0 == strcmp(buf, "75")); //u
  hex_format_byte_as_hex(objs->large[51], buf);
  ASSERT(0 == strcmp(buf, "78")); //x
  hex_format_byte_as_hex(objs->large[52], buf);
  ASSERT(0 == strcmp(buf, "20")); //' ' 
  hex_format_byte_as_hex(objs->large[53], buf);
  ASSERT(0 == strcmp(buf, "6f")); //o
}

void testHexToPrintable(TestObjs *objs) {
  //printable char test 
  ASSERT('H' == hex_to_printable(objs->test_data_1[0]));
  ASSERT('e' == hex_to_printable(objs->test_data_1[1]));
  //non printable char test
  ASSERT('.' == hex_to_printable(objs->test_data_1[13]));
  ASSERT('.' == hex_to_printable(objs->test_data_1[14]));
  ASSERT('.' == hex_to_printable(objs->nonprintable[0]));
  ASSERT('.' == hex_to_printable(objs->nonprintable[1]));
  //empty string test
  ASSERT('.' == hex_to_printable(objs->empty[0]));
  //boundary test
  ASSERT('G' == hex_to_printable(objs->multipleOf16[14]));
  ASSERT('.' == hex_to_printable(objs->multipleOf16[15]));
  //test small non-printable number
  ASSERT('.' == hex_to_printable(0L));
  ASSERT('.' == hex_to_printable(1L));
  //test boundary
  ASSERT(' ' == hex_to_printable(32L));
  ASSERT('!' == hex_to_printable(33L));
  //test boundary
  ASSERT('~' == hex_to_printable(126L));
  ASSERT('.' == hex_to_printable(127L));
  ASSERT('.' == hex_to_printable(128L));
  //test unnessary large number
  ASSERT('.' == hex_to_printable(255L));
}
