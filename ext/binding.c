/*
  Copyright 2008 Suraj N. Kurapati
  See the file named LICENSE for details.
*/

#include "binding.h"
#include "swig.cin" // SWIG generated bindings for VPI

void RubyVPI_binding_init()
{
    Init_VPI();

    // some compilers have trouble with pointers to the va_list
    // type.  See ext/Rakefile and the user manual for details
    rb_define_alias(mVPI, "vpi_vprintf", "vpi_printf");
    rb_define_alias(mVPI, "vpi_mcd_vprintf", "vpi_mcd_printf");
}

VALUE RubyVPI_binding_rubify_callback(p_cb_data aCallback)
{
    return SWIG_NewPointerObj(aCallback, SWIGTYPE_p_t_cb_data, 0);
}
