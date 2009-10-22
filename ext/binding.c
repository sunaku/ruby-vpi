//
// Copyright protects this work.
// See LICENSE file for details.
//

#include "binding.h"
#include "relay.h"

// insert the SWIG-generated Ruby bindings for Verilog VPI here
#include "swig.cin"

void RubyVPI_binding_init()
{
    Init_VPI();

    // allows Ruby to relay control to the Verilog simulator
    rb_define_module_function(mVPI, "relay", RubyVPI_relay_from_ruby_to_vlog, 0);

    // some compilers have trouble with pointers to the va_list
    // type.  see ext/Rakefile and the user manual for details
    rb_define_alias(mVPI, "vpi_vprintf", "vpi_printf");
    rb_define_alias(mVPI, "vpi_mcd_vprintf", "vpi_mcd_printf");
}

VALUE RubyVPI_binding_rubify_callback(p_cb_data aCallback)
{
    return SWIG_NewPointerObj(aCallback, SWIGTYPE_p_t_cb_data, 0);
}
