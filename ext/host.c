/*
  Copyright 2008 Suraj N. Kurapati
  See the file named LICENSE for details.
*/

#include "host.h"
#include "util.h"
#include "user.h"
#include "thread.h"
#include "binding.h"
#include <ruby.h>
#include <stdlib.h>

static pthread_attr_t RubyVPI_host_gAttr;
static pthread_t RubyVPI_host_gThread;
static pthread_mutex_t RubyVPI_host_gLock;
static pthread_cond_t RubyVPI_host_gCond;

static bool RubyVPI_host_gDoingInit;
static bool RubyVPI_host_gDoingFini;
static bool RubyVPI_host_gDoingRelay;
static bool RubyVPI_host_gCeaseRelay;

static p_cb_data RubyVPI_host_gCallback;


///
/// @see RubyVPI_thread_wait
///
static inline void RubyVPI_host_wait(bool* state, bool value)
{
    RubyVPI_thread_wait(&RubyVPI_host_gLock, &RubyVPI_host_gCond, state, value);
}

///
/// @see RubyVPI_thread_flag
///
static inline void RubyVPI_host_flag(bool* state, bool value)
{
    RubyVPI_thread_flag(&RubyVPI_host_gLock, &RubyVPI_host_gCond, state, value);
}

#ifdef RUBY_GLOBAL_SETUP
RUBY_GLOBAL_SETUP
#endif

///
/// Body of the host thread.
///
static void* RubyVPI_host_body(void* aDummy)
{
    RubyVPI_util_debug("Host: begin init");
    RubyVPI_host_wait(&RubyVPI_host_gDoingInit, true);

/*
        // ruby thinks it's running inside an entire process, so it uses
        // getrlimit() to determine maximum stack size.  we fix this by
        // setting ruby's maximum stack size to that of this pthread
        RubyVPI_util_debug("Host: alloc stack");

        RubyVPI_host_gStack = 0;
        RubyVPI_host_gStackSize = 0;

        unsigned char power;
        for (power = 22; power > 0; power--) // start at 2**22 (41 MiB)
        {
            RubyVPI_host_gStackSize = 1 << power;
            RubyVPI_host_gStack = malloc(RubyVPI_host_gStackSize);

            if (RubyVPI_host_gStack)
                break;
        }

        if (!RubyVPI_host_gStack)
        {
            RubyVPI_util_error("unable to allocate memory for Ruby's stack");
        }

        RubyVPI_util_debug("Host: stack is %p (%d bytes)", RubyVPI_host_gStack, RubyVPI_host_gStackSize);
        // ruby_init_stack(RubyVPI_host_gStack);
        // ruby_set_stack_size(RubyVPI_host_gStackSize);
*/


        //
        // ruby init
        //

        #ifdef RUBY_INIT_STACK
        RubyVPI_util_debug("Host: RUBY_INIT_STACK");
        RUBY_INIT_STACK;
        #endif

        RubyVPI_util_debug("Host: ruby_init()");
        ruby_init();

        // override Ruby's hooked handlers for $0 so that $0 can be
        // treated as pure Ruby value (and modified without restriction)
        RubyVPI_util_debug("Host: redefine $0 hooked variable");
        VALUE progName = rb_str_new2("ruby-vpi");
        rb_define_variable("$0", &progName);
        rb_define_variable("$PROGRAM_NAME", &progName);

        RubyVPI_util_debug("Host: ruby_init_loadpath()");
        ruby_init_loadpath();

        #ifdef HAVE_RUBY_1_9
        RubyVPI_util_debug("Host: ruby_init_gems(Qtrue)");
        rb_const_set(rb_define_module("Gem"), rb_intern("Enable"), Qtrue);

        RubyVPI_util_debug("Host: Init_prelude()");
        Init_prelude();
        #endif


        //
        // VPI bindings init
        //

        RubyVPI_util_debug("Host: VPI binding init");
        RubyVPI_binding_init();


        //
        // ruby thread init
        //

        RubyVPI_util_debug("Host: user_init()");
        RubyVPI_user_init();

    RubyVPI_host_flag(&RubyVPI_host_gDoingInit, false);
    RubyVPI_util_debug("Host: end init");


    // relay "resume" messages from simulator to user
    RubyVPI_util_debug("Host: begin relay");

    VALUE target = rb_const_get(rb_cObject, rb_intern("RubyVPI"));
    ID method = rb_intern("resume");

    while (true)
    {
        RubyVPI_host_wait(&RubyVPI_host_gDoingRelay, true);

        if (RubyVPI_host_gCeaseRelay)
        {
            break;
        }

        RubyVPI_util_debug("Host: ruby callback for %p =>", RubyVPI_host_gCallback);
        VALUE call = RubyVPI_binding_rubyize_callback(RubyVPI_host_gCallback);
        rb_p(call);

        RubyVPI_util_debug("Host: calling RubyVPI.resume");
        rb_funcall(target, method, 1, call); // pass callback to user code

        RubyVPI_host_flag(&RubyVPI_host_gDoingRelay, false);
    }

    RubyVPI_util_debug("Host: end relay");


    RubyVPI_util_debug("Host: begin fini");
    RubyVPI_host_wait(&RubyVPI_host_gDoingFini, true);

        RubyVPI_util_debug("Host: user fini");
        RubyVPI_user_fini();

        RubyVPI_util_debug("Host: ruby_finalize()");
        ruby_finalize();

        // RubyVPI_util_debug("Host: free stack");
        // free(RubyVPI_host_gStack);

    RubyVPI_host_flag(&RubyVPI_host_gDoingFini, false);
    RubyVPI_util_debug("Host: end fini");

    pthread_exit(0);
}

PLI_INT32 RubyVPI_host_init(p_cb_data aCallback)
{
    // pthreads init
    RubyVPI_util_debug("Main: pthreads init");

    pthread_mutex_init(&RubyVPI_host_gLock, 0);
    pthread_cond_init(&RubyVPI_host_gCond, 0);

    RubyVPI_host_gDoingInit = false;
    RubyVPI_host_gDoingFini = false;
    RubyVPI_host_gDoingRelay = false;
    RubyVPI_host_gCeaseRelay = false;


    // host thread init
    RubyVPI_util_debug("Main: host thread init");

    pthread_create(&RubyVPI_host_gThread, 0, RubyVPI_host_body, 0);
    RubyVPI_host_flag(&RubyVPI_host_gDoingInit, true);
    RubyVPI_host_wait(&RubyVPI_host_gDoingInit, false);
}

PLI_INT32 RubyVPI_host_fini(p_cb_data aCallback)
{
    // user relay fini
    RubyVPI_util_debug("Main: host relay fini");

    RubyVPI_host_gCeaseRelay = true;
    RubyVPI_host_flag(&RubyVPI_host_gDoingRelay, true);


    // host thread fini
    RubyVPI_util_debug("Main: host thread fini");

    RubyVPI_host_flag(&RubyVPI_host_gDoingFini, true);
    RubyVPI_host_wait(&RubyVPI_host_gDoingFini, false);


    // pthreads fini
    RubyVPI_util_debug("Main: pthreads fini");

    pthread_cond_destroy(&RubyVPI_host_gCond);
    pthread_mutex_destroy(&RubyVPI_host_gLock);
}

PLI_INT32 RubyVPI_host_resume(p_cb_data aCallback)
{
    RubyVPI_util_debug("Main: callback = %p", aCallback);

    if (aCallback)
    {
        RubyVPI_util_debug("Main: callback.user_data = %p", aCallback->user_data);
    }
    else
    {
        RubyVPI_util_debug("Main: callback is NULL");
    }

    RubyVPI_host_gCallback = aCallback;
    RubyVPI_host_flag(&RubyVPI_host_gDoingRelay, true);
    RubyVPI_host_wait(&RubyVPI_host_gDoingRelay, false);

    return 0;
}
