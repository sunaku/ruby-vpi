//
// Copyright protects this work.
// See LICENSE file for details.
//

#ifndef RUBY_VPI_RELAY_H
#define RUBY_VPI_RELAY_H

  #include "verilog.h"
  #include <ruby.h>

  void RubyVPI_relay_init_vlog_context();

  PLI_INT32 RubyVPI_relay_from_vlog_to_ruby(p_cb_data callback);

  VALUE RubyVPI_relay_from_ruby_to_vlog(VALUE self);

#endif
