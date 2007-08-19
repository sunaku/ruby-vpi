%module VPI

/* Parse the header file to generate wrappers */
%{
#include "swig_vpi.h"
%}
%include "swig_vpi.h"

/* Allows us set the VPI callback handler in Ruby:

    data        = S_cb_data.new
    data.cb_rtn = VPI::Vlog_relay_ruby
*/
%{
#include "vlog.h"
%}
%constant PLI_INT32 vlog_relay_ruby(struct t_cb_data *);
