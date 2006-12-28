/*
  Copyright 1999 Kazuhiro HIWADA
  Copyright 2006 Suraj N. Kurapati

  This file is part of Ruby-VPI.

  Ruby-VPI is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  Ruby-VPI is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Ruby-VPI; if not, write to the Free Software Foundation,
  Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#include "main.h"
#include "relay.h"
#include <stdlib.h>
#include <stdio.h>


/* load the SWIG-generated Ruby interface to VPI */
#include "swig_wrap.cin"


void main_init() {
  ruby_init();
  ruby_init_loadpath();

  /* load the VPI interface for Ruby */
    Init_vpi();
    rb_define_module_function(mVpi, "relay_verilog", main_relay_verilog, 0);

  /* initialize the Ruby bench */
    char* benchFile = getenv("RUBY_VPI__RUBY_BENCH_FILE");

    if (benchFile != NULL) {
      rb_load_file(benchFile);
    }
    else {
      common_printf("error: environment variable RUBY_VPI__RUBY_BENCH_FILE is not set.");
      exit(EXIT_FAILURE);
    }

    ruby_script(benchFile);

  /* run the test bench */
    ruby_run();

  ruby_finalize();
}

VALUE main_relay_verilog(VALUE arSelf) {
  relay_verilog();
  return arSelf;
}
