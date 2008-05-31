/*
  Copyright 2008 Suraj N. Kurapati
  See the file named LICENSE for details.
*/
///\file Ruby bindings for the VPI library.

#ifndef BINDING_H
#define BINDING_H

    #include "verilog.h"
    #include <ruby.h>

    ///
    /// Initializes the Ruby bindings.
    ///
    /// This function must be called ONLY from the
    /// main C process (NOT from inside a thread).
    ///
    /// Also, this function must be called ONLY
    /// after RubyVPI_roobee_init() has been called.
    ///
    void RubyVPI_binding_init();

    ///
    /// Converts the given VPI callback structure into a Ruby value.
    ///
    VALUE RubyVPI_binding_rubify_callback(p_cb_data aCallback);

#endif
