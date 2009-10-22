%module VPI

/* Parse the header file to generate wrappers */
%{
    #include "swig_vpi.h"
%}
%include "swig_vpi.h"

/* Allow the VPI callback handler function to be set from Ruby:

    data = S_cb_data.new
    data.cb_rtn = VPI::RubyVPI_user_resume
*/
%{
    #include "relay.h"
%}
%constant PLI_INT32 RubyVPI_relay_from_vlog_to_ruby(p_cb_data);
