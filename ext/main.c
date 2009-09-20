/*
  Copyright 2006 Suraj N. Kurapati
  See the file named LICENSE for details.
*/

#include "util.h"
#include "verilog.h"
#include <stdio.h>

///
/// Registers a very basic VPI callback with reason and handler.
///
static void RubyVPI_main_register_callback(PLI_INT32 aReason, s_vpi_time* time, PLI_INT32 (*aHandler)(p_cb_data))
{
    s_cb_data call;

    call.reason    = aReason;
    call.cb_rtn    = aHandler;
    call.obj       = 0;
    call.time      = time;
    call.value     = 0;
    call.user_data = 0;

    vpi_free_object(vpi_register_cb(&call));
}

PLI_INT32 test_begin(p_cb_data callback);
PLI_INT32 test_loop(p_cb_data callback);
PLI_INT32 test_end(p_cb_data callback);

PLI_INT32 test_begin(p_cb_data callback)
{
    static char static_local;
    char dynamic_local;
    RubyVPI_util_puts("Main: test_begin: dynamic=%p static=%p", &dynamic_local, &static_local);

    s_vpi_time time;
    time.type = vpiSimTime;
    time.high = 0;
    time.low = 1;

    RubyVPI_util_debug("Main: test_begin: registering FIRST loop callback");
    RubyVPI_main_register_callback(cbAfterDelay, &time, test_loop);

    return 0;
}

PLI_INT32 test_loop(p_cb_data callback)
{
    static char static_local;
    char dynamic_local;
    RubyVPI_util_puts("Main: test_loop: dynamic=%p static=%p", &dynamic_local, &static_local);

    s_vpi_time time;
    time.type = vpiSimTime;
    time.high = 0;
    time.low = 1;

    RubyVPI_util_debug("Main: test_loop: registering LOOP callback");
    RubyVPI_main_register_callback(cbAfterDelay, &time, test_loop);

    return 0;
}

PLI_INT32 test_end(p_cb_data callback)
{
    static char static_local;
    char dynamic_local;
    RubyVPI_util_puts("Main: test_end: dynamic=%p static=%p", &dynamic_local, &static_local);

    return 0;
}

static void RubyVPI_main_init()
{
    RubyVPI_util_debug("Main: at vlog startup");

    // commence Ruby execution at the start of the simulation
    RubyVPI_util_debug("Main: registering BEGIN simulation callback");
    RubyVPI_main_register_callback(cbStartOfSimulation, 0, test_begin);

    // clean up this C extension at the end of the simulation
    RubyVPI_util_debug("Main: registering END simulation callback");
    RubyVPI_main_register_callback(cbEndOfSimulation, 0, test_end);
}

///
/// Verilog simulator's bootstrap vector.  The simulator
/// will invoke the functions in this array when it loads
/// the shared-object file compiled from this C extension.
///
void (*vlog_startup_routines[])() = { RubyVPI_main_init, 0 };

#if defined(PRAGMATIC_CVER) || defined(SYNOPSYS_VCS) || defined(CADENCE_NCSIM)
    ///
    /// Invokes each routine specified in the vlog_startup_routines array.
    ///
    void vlog_startup_routines_bootstrap()
    {
        unsigned int i;
        for (i = 0; vlog_startup_routines[i]; i++)
        {
            vlog_startup_routines[i]();
        }
    }
#endif
