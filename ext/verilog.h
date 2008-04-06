/*
  Copyright 2006 Suraj N. Kurapati
  See the file named LICENSE for details.
*/
///\file A proxy for all Verilog headers of interest to us.

#ifndef VERILOG_H
#define VERILOG_H

    // Use our verbatim copy of the official IEEE Std 1364-2005
    // header file, which was obtained from this URL:
    // http://www.boydtechinc.com/ptf/archive/ptf_2005/0737.html
    #include "vpi_user.h"

    ///
    /// Registers a very basic VPI callback with reason and handler.
    ///
    static void RubyVPI_verilog_register_callback(PLI_INT32 aReason, PLI_INT32    (*aHandler)(p_cb_data));

#endif
