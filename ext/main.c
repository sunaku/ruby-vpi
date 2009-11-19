//
// Copyright protects this work.
// See LICENSE file for details.
//

#include <stdbool.h>
#include <stdlib.h>

#ifdef HAVE_SYS_UCONTEXT_H
#include <sys/ucontext.h>
#endif

#ifdef HAVE_CONTEXT_H
#include <ucontext.h>
#endif

#include <ruby.h>
#include "verilog.h"
#include "kernel.h"

static ucontext_t main_context;
static ucontext_t ruby_context;
static char*      ruby_context_stack      = NULL;
static size_t     ruby_context_stack_size = 4*(1024*1024); // 4 MiB

static void relay_from_main_to_ruby()
{
    printf("Relay: main => ruby\n");
    swapcontext(&main_context, &ruby_context);
    printf("Relay: main <= ruby\n");
}

static VALUE relay_from_ruby_to_main(VALUE self)
{
    printf("Relay: ruby => main\n");
    swapcontext(&ruby_context, &main_context);
    printf("Relay: ruby <= main\n");
    return Qnil;
}

static VALUE ruby_context_body_require(const char* file)
{
    int error;
    VALUE result = rb_protect((VALUE (*)(VALUE))rb_require,
                              (VALUE)file, &error);

    if (error)
    {
        printf("rb_require('%s') failed with status=%d\n",
               file, error);

        VALUE exception = rb_gv_get("$!");
        if (RTEST(exception))
        {
            printf("... because an exception was raised:\n");
            fflush(stdout);

            VALUE inspect = rb_inspect(exception);
            rb_io_puts(1, &inspect, rb_stderr);

            VALUE backtrace = rb_funcall(
                exception, rb_intern("backtrace"), 0);
            rb_io_puts(1, &backtrace, rb_stderr);
        }
    }

    return result;
}

static void ruby_context_body(VALUE* stack_lower_bound, VALUE* stack_upper_bound)
{
    printf("Context: begin\n");

    int i;
    for (i = 0; i < 2; i++)
    {
        printf("Context: relay %d\n", i);
        relay_from_ruby_to_main(Qnil);
    }

    printf("Context: Ruby begin\n");

    #ifdef HAVE_RUBY_SYSINIT
    int argc = 0;
    char** argv = {""};
    ruby_sysinit(&argc, &argv);
    #endif
    {
        #ifdef HAVE_RUBY_BIND_STACK
        ruby_bind_stack(stack_lower_bound, stack_upper_bound);
        #endif

        RUBY_INIT_STACK;
        ruby_init();
        ruby_init_loadpath();

        /* allow Ruby script to relay */
        rb_define_module_function(rb_mKernel, "relay_from_ruby_to_main",
                                  relay_from_ruby_to_main, 0);

        /* run the "hello world" Ruby script */
        printf("Ruby: require 'hello' begin\n");
        ruby_context_body_require("./hello.rb");
        printf("Ruby: require 'hello' end\n");

        ruby_cleanup(0);
    }

    printf("Context: Ruby end\n");

    printf("Context: end\n");

    ruby_context_finished = true;
    relay_from_ruby_to_main(Qnil);
}

#ifdef RUBY_GLOBAL_SETUP
RUBY_GLOBAL_SETUP
#endif

int RubyVPI(int argc, char** argv, size_t stack_size)
{
    /* create System V context to house Ruby */
    ruby_context_stack_size = sizeof(ruby_context_stack);

    ruby_context.uc_link          = &main_context;
    ruby_context.uc_stack.ss_sp   = ruby_context_stack;
    ruby_context.uc_stack.ss_size = ruby_context_stack_size;
    getcontext(&ruby_context);
    makecontext(&ruby_context, (void (*)(void)) ruby_context_body, 0);

    /* relay control to Ruby until it is finished */
    ruby_context_finished = false;
    while (!ruby_context_finished)
    {
        relay_from_main_to_ruby();
    }

    printf("Main: Goodbye!\n");
    return 0;
}

///
/// Registers a very basic VPI callback with reason and handler.
///
static void RubyVPI_main_register_callback(PLI_INT32 aReason, PLI_INT32 (*aHandler)(p_cb_data))
{
    s_cb_data call;

    call.reason    = aReason;
    call.cb_rtn    = aHandler;
    call.obj       = 0;
    call.time      = 0;
    call.value     = 0;
    call.user_data = 0;

    vpi_free_object(vpi_register_cb(&call));
}

static void RubyVPI_main_init()
{
    RubyVPI_util_debug("inside vlog startup routines");

    // commence Ruby execution at the start of the simulation
    RubyVPI_util_debug("registering BEGIN simulation callback");
    RubyVPI_main_register_callback(cbStartOfSimulation, RubyVPI_vlog_init);

    // clean up this C extension at the end of the simulation
    RubyVPI_util_debug("registering END simulation callback");
    RubyVPI_main_register_callback(cbEndOfSimulation, RubyVPI_vlog_fini);
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
