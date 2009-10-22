//
// Copyright protects this work.
// See LICENSE file for details.
//

#include <stdbool.h>
#include "util.h"
#include "vlog.h"
#include "ruby.h0"
#include "relay.h"

PLI_INT32 RubyVPI_vlog_init(p_cb_data callback)
{
    RubyVPI_util_debug("init");

    volatile bool need_to_run_ruby = true;
    RubyVPI_relay_init_vlog_context();

    if (need_to_run_ruby)
    {
        need_to_run_ruby = false;

        RubyVPI_util_debug("start ruby");
        int exit_status = RubyVPI_ruby_run();
        RubyVPI_util_debug("ruby finished with status %d", exit_status);

        // TODO: propagate exit status through Verilog simulator using VPI
        return exit_status;
    }
    else
    {
        RubyVPI_util_debug("relay has begun.. deferring to self-generative callbacks");

        return 0;
    }
}

PLI_INT32 RubyVPI_vlog_fini(p_cb_data callback)
{
    RubyVPI_util_debug("fini");
    return 0;
}
