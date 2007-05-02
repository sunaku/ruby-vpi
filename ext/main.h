/*
  Copyright 2006 Suraj N. Kurapati
  See the file named LICENSE for details.
*/
/**\file
  The C extension for Ruby-VPI.
*/

#ifndef MAIN_H
#define MAIN_H

  #include "common.h"
  #include <ruby.h>

  /**
    Runs the test bench.
  */
  void main_init();

  /**
    Transfers control from Ruby to Verilog.
  */
  VALUE main_relay_verilog(VALUE arSelf);

  /**
    Gets the reason (Vpi::S_cb_data) why Verilog relayed to Ruby.
  */
  VALUE main_relay_ruby_reason(VALUE arSelf);

#endif
