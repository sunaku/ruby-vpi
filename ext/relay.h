/*
  Copyright 2006 Suraj N. Kurapati
  See the file named LICENSE for details.
*/
///\file co-simulation relay mechanism

#ifndef RELAY_H
#define RELAY_H

    #include "roobee.h"

    ///
    /// Initializes the relay mechanism and exports
    /// the "relay_to_verilog" method to Ruby.
    ///
    /// This function must be called ONLY from the
    /// main C process (NOT from inside a thread).
    ///
    /// Also, this function must be called ONLY
    /// after RubyVPI_roobee_init() has been called.
    ///
    static void RubyVPI_relay_init();

    ///
    /// Allows the C program to continue execution.
    ///
    static void RubyVPI_relay_wake_up_c();

    ///
    /// Makes the Ruby thread wait until the
    /// C program finishes running (for now).
    ///
    static VALUE RubyVPI_relay_wait_for_c();

    ///
    /// Transfers control from the C program
    /// to the Ruby script and pauses the C program.
    ///
    /// This function must be invoked only by the C program.
    ///
    static PLI_INT32 RubyVPI_relay_from_c_to_ruby(p_cb_data aCallback);

#endif
