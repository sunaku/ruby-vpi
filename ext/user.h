/*
  Copyright 2008 Suraj N. Kurapati
  See the file named LICENSE for details.
*/

#ifndef USER_H
#define USER_H

    #include "verilog.h"

    // should be called in vlog_startup_routines
    void RubyVPI_user_init();

    // should be called at end of simulation
    void RubyVPI_user_fini();

#endif
