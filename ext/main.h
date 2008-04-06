/*
  Copyright 2008 Suraj N. Kurapati
  See the file named LICENSE for details.
*/
///\file The main C extension.

#ifndef MAIN_H
#define MAIN_H

    #include "verilog.h"

    ///
    /// The main C function that is invoked to bootstrap this C extension.
    ///
    static PLI_INT32 RubyVPI_main_init(p_cb_data aCallback);

    ///
    /// The main C function that is invoked at the end
    /// of simulation to tear down this C extension.
    ///
    static PLI_INT32 RubyVPI_main_fini(p_cb_data aCallback);

#endif
