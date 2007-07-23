%module vpi

/* Parse the header file to generate wrappers */
%{
#include "swig_vpi.h"
%}
%include "swig_vpi.h"

/* allows us to set S_cb_data.cb_rtn = Vpi::Vlog_relay_ruby in Ruby */
%{
#include "vlog.h"
%}
%constant PLI_INT32 vlog_relay_ruby(struct t_cb_data *);
