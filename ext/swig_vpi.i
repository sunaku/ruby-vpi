%feature("autodoc", "2"); /* http://www.swig.org/Doc1.3/Ruby.html#Ruby_nn67 */

%module "Vpi"

/* Parse thhe header file to generate wrappers */
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
