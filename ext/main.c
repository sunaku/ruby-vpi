/*
  Copyright 1999 Kazuhiro HIWADA
  Copyright 2006 Suraj N. Kurapati
  See the file named LICENSE for details.
*/

#include "main.h"
#include "relay.h"
#include <stdlib.h>
#include <stdio.h>


// load the SWIG-generated Ruby interface to VPI
#include "swig_wrap.cin"


void main_init() {
  ruby_init();
  ruby_init_loadpath();

  // load the VPI interface for Ruby
    Init_vpi();
    rb_define_module_function(mVpi, "relay_verilog", main_relay_verilog, 0);
    rb_define_module_function(mVpi, "relay_ruby_reason", main_relay_ruby_reason, 0);

    // some compilers have trouble with pointers to the va_list
    // type.  See ext/Rakefile and the user manual for details
    rb_define_alias(mVpi, "vpi_vprintf", "vpi_printf");
    rb_define_alias(mVpi, "vpi_mcd_vprintf", "vpi_mcd_printf");


  char* bootLoader = getenv("RUBYVPI_BOOT_LOADER");
  char* bootTarget = getenv("RUBYVPI_BOOT_TARGET");

  if (bootLoader != NULL && bootTarget != NULL) {
    ruby_script(bootTarget);
    rb_load_file(bootLoader);
    ruby_run();
  }
  else {
    common_printf("error: the RUBYVPI_BOOT_LOADER and RUBYVPI_BOOT_TARGET environment variables are not initialized.");
    exit(EXIT_FAILURE);
  }
}

VALUE main_relay_verilog(VALUE arSelf) {
  relay_verilog();
  return arSelf;
}

VALUE main_relay_ruby_reason(VALUE arSelf) {
  return SWIG_NewPointerObj(vlog_relay_ruby_reason(), SWIGTYPE_p_t_cb_data, 0);
}
