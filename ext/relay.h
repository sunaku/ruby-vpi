/*
  Copyright 1999 Kazuhiro HIWADA
  Copyright 2006 Suraj N. Kurapati
  See the file named LICENSE for details.
*/
/**\file
  Logic for transferring control between Ruby and Verilog.
*/

#ifndef RELAY_H
#define RELAY_H

  #include "common.h"

  /**
    Initialize the relay mechanism, which enables Verilog to
    transfer control to Ruby and vice versa, and start Ruby.
  */
  void relay_init();

  /**
    Transfers control to Ruby.
  */
  void relay_ruby();

  /**
    Transfers control to Verilog.
  */
  void relay_verilog();

#endif
