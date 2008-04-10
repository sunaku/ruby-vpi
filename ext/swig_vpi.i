%module VPI

/* Parse the header file to generate wrappers */
%{
    #include "swig_vpi.h"
%}
%include "swig_vpi.h"

/* Allow the VPI callback handler function to be set from Ruby:

    data = S_cb_data.new
    data.cb_rtn = VPI::RubyVPI_relay_from_host_to_ruby
*/
%{
    #include "host.h"
%}
%constant PLI_INT32 RubyVPI_host_resume(p_cb_data);
