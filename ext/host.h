/*
  Copyright 2008 Suraj N. Kurapati
  See the file named LICENSE for details.
*/

#ifndef HOST_H
#define HOST_H

    #include "verilog.h"

    // should be called in vlog_startup_routines
    PLI_INT32 RubyVPI_host_init(p_cb_data aCallback);

    // should be called at end of simulation
    PLI_INT32 RubyVPI_host_fini(p_cb_data aCallback);

#endif
