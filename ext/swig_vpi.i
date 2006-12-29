%module vpi


/* Parse the header file to generate wrappers */
%{
#include "vpi_user.h"
%}
%include "vpi_user.h"


/* allows us to set S_cb_data.cb_rtn = Vpi::Vlog_relay_ruby from Ruby */
%{
#include "vlog.h"
%}
%constant PLI_INT32 vlog_relay_ruby(struct t_cb_data *);
