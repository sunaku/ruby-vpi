/*
  Copyright 2006 Suraj N. Kurapati
  See the file named LICENSE for details.
*/
/**\file
  Things common to all Ruby-VPI code.
*/

#ifndef COMMON_H
#define	COMMON_H

  #include <stddef.h>
  #include "verilog.h"


  /**
    A wrapper for vpi_printf() which marks the given message as being emitted
    from Ruby-VPI and ends the message with a new line.

    @param	...	Arguments to vpi_printf()
  */
  #define common_printf(...) vpi_printf("Ruby-VPI: "); vpi_printf(__VA_ARGS__); vpi_printf("\n");

  /**
    A wrapper for common_printf() which marks the given message as being
    debugging output.
  */
  #ifdef DEBUG
    #define common_debug(...) vpi_printf("(%s:%d) ", __FILE__, __LINE__); common_printf(__VA_ARGS__);
  #else
    #define common_debug(...)
  #endif

  /**
    A boolean variable with two possible values: true and false. Pass aroung
    this value instead of zero and non-zero integers.
  */
  typedef enum { false = 0, true = 1 } bool;

  /**
    Returns the string "true" if the given boolean expression is true. Otherwise
    returns the string "false".
  */
  #define common_boolToStr(aBoolExpr)	( (aBoolExpr) ? "true" : "false" )

#endif
