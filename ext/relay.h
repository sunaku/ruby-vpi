//
// Copyright protects this work.
// See LICENSE file for details.
//

#ifndef RUBY_VPI_RELAY_H
#define RUBY_VPI_RELAY_H

  #include "verilog.h"
  #include <ruby.h>

  void relay_init_main_context();

  PLI_INT32 relay_from_main_to_ruby(p_cb_data callback);

  VALUE relay_from_ruby_to_main(VALUE self);

#endif
