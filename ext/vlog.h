/*
  Copyright 2006 Suraj N. Kurapati
  See the file named LICENSE for details.
*/
/**\file
  Interface between C and Verilog code.
*/

#ifndef VLOG_H
#define VLOG_H

  #include "common.h"
  #include "verilog.h"

  /**
    Relays control from Verilog to Ruby.
  */
  verilog_cb_funcSig(vlog_relay_ruby);

  /**
    Returns the data corresponding to the callback that caused the relay from
    Verilog to Ruby.
  */
  s_cb_data* vlog_relay_ruby_reason();

#endif
