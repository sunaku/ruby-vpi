/*
  Copyright 2008 Suraj N. Kurapati
  See the file named LICENSE for details.
*/

#include <stddef.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>
#include <sys/ucontext.h>
#include <ruby.h>
#include "host.h"
#include "util.h"
#include "user.h"
#include "binding.h"

static ucontext_t user_context;
static ucontext_t host_context;

static void host_to_user()
{
    RubyVPI_util_debug("Ruby: host_to_user() begin");
    getcontext(&host_context);
    setcontext(&user_context);
    RubyVPI_util_debug("Ruby: host_to_user() end");
}

static void user_to_host()
{
    RubyVPI_util_debug("Ruby: user_to_host() begin");
    getcontext(&user_context);
    setcontext(&host_context);
    RubyVPI_util_debug("Ruby: user_to_host() end");
}

static bool relay_begun = false;

//
// Creates a coroutine to house the ruby interpreter.
//
static void ruby_coroutine_body()
{
    relay_begun = true;

    //
    // ruby init
    //

    int argc = 0;
    RubyVPI_util_debug("Host: pcl stack begins at (%p)", &argc);
    char** argv = {""};
    RubyVPI_util_debug("Host: ruby_sysinit(%d, %p)", argc, argv);
    ruby_sysinit(&argc, &argv);

    VALUE dummy;
    VALUE* stack_start = &dummy; // + 0x1000;
    RubyVPI_util_debug("Host: ruby_init_stack(%p)", stack_start);
    ruby_init_stack(stack_start);

    // RubyVPI_util_debug("Ruby: co_resume() EARLY");
    // user_to_host();
    // RubyVPI_util_debug("Ruby: co_resume() => done");

    RubyVPI_util_debug("Host: ruby_init()");
    ruby_init();

    RubyVPI_util_debug("Ruby: co_resume() LATE");
    user_to_host();
    RubyVPI_util_debug("Ruby: co_resume() => done");

    RubyVPI_util_debug("Host: ruby_init_loadpath()");
    ruby_init_loadpath();

    RubyVPI_util_debug("Host: ruby_script()");
    ruby_script("ruby-vpi");


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

    RubyVPI_util_debug("Host: user_init() DONE");


    // clean up

    RubyVPI_util_debug("Host: user fini");
    RubyVPI_user_fini();

    VALUE err = rb_gv_get("$!");
    if (RTEST(err))
    {
        RubyVPI_util_debug("Host: An exception was raised:");

        VALUE dump = rb_inspect(err);
        rb_io_puts(1, &dump, rb_stderr);

        VALUE trace = rb_funcall(err, rb_intern("backtrace"), 0);
        rb_io_puts(1, &trace, rb_stderr);
    }

    RubyVPI_util_debug("Host: ruby_cleanup()");
    ruby_cleanup(0); // make sure it dosen't call exit()
    RubyVPI_util_debug("Host: ruby_cleanup() => done");

    RubyVPI_util_debug("Host: co_exit()");
    co_exit();
    RubyVPI_util_debug("Host: co_exit() => done");
}

static char user_context_stack[SIGSTKSZ];

PLI_INT32 RubyVPI_host_init(p_cb_data aCallback)
{
    RubyVPI_util_debug("Host: co_create()");

    // size_t stack_size = 4096;
    // char* stack = malloc(sizeof(char) * stack_size);
    // ruby_coroutine = co_create(ruby_coroutine_body, NULL, stack, stack_size);
    // user_context.uc_link = &host_context;
    // user_context.uc_stack.ss_sp = user_context_stack;
    getcontext(&host_context);

    if (!relay_begun) {
        RubyVPI_util_debug("Host: co_call()");
        ruby_coroutine_body();
        RubyVPI_util_debug("Host: co_call() => done");
    }
    else {
        RubyVPI_util_debug("Host: relay has begun.. deferring to self-generative callbacks");
    }

    return 0;
}

PLI_INT32 RubyVPI_host_fini(p_cb_data aCallback)
{
    RubyVPI_util_debug("Host: fini");
    return 0;
}

#include "user.h"
#include "util.h"
#include "binding.h"

static VALUE RubyVPI_user_require_impl(VALUE aPath)
{
    return rb_require(StringValueCStr(aPath));
}

static VALUE RubyVPI_user_require(VALUE aPath)
{
    int status = 0;
    VALUE result = rb_protect(RubyVPI_user_require_impl, aPath, &status);

    if (status)
    {
        RubyVPI_util_error("rb_require('%s') failed with status %d", StringValueCStr(aPath), status);
    }

    return result;
}

void RubyVPI_user_init()
{
    RubyVPI_user_require(rb_str_new2("ruby-vpi/boot/loader"));
}

void RubyVPI_user_fini()
{
    // Ruby will garbage collect everything else
}

#include <pcl.h>
#include "binding.h"
#include "swig.cin" // SWIG generated bindings for VPI
#include "user.h"
#include "host.h"

p_cb_data the_relay_reason = NULL;

VALUE do_the_relay(VALUE self)
{
    RubyVPI_util_debug("Ruby: co_current() => %p", co_current());

    RubyVPI_util_debug("Ruby: co_resume()");
    user_to_host();
    RubyVPI_util_debug("Ruby: co_resume() => done");

    // TODO: read the callback response here!

    return Qnil;
}

VALUE RubyVPI_binding_rubify_callback(p_cb_data aCallback)
{
    return SWIG_NewPointerObj(aCallback, SWIGTYPE_p_t_cb_data, 0);
}

// pass VPI callback to user code as Ruby object
VALUE get_relay_reason(VALUE self)
{
    return RubyVPI_binding_rubify_callback(the_relay_reason);
}

void RubyVPI_binding_init()
{
    Init_VPI();

    // some compilers have trouble with pointers to the va_list
    // type.  See ext/Rakefile and the user manual for details
    rb_define_alias(mVPI, "vpi_vprintf", "vpi_printf");
    rb_define_alias(mVPI, "vpi_mcd_vprintf", "vpi_mcd_printf");

    rb_define_module_function(mVPI, "do_the_relay", do_the_relay, 0);
    rb_define_module_function(mVPI, "get_relay_reason", get_relay_reason, 0);
}

PLI_INT32 RubyVPI_user_resume(p_cb_data aCallback)
{
    RubyVPI_util_debug("Main: callback = %p", aCallback);
    RubyVPI_util_debug("Main: callback.user_data = %p", aCallback ? aCallback->user_data : 0);

    RubyVPI_util_debug("Main: calling RubyVPI.resume");
    the_relay_reason = aCallback;
    host_to_user();

    return 0;
}
