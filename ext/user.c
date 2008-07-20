/*
  Copyright 2008 Suraj N. Kurapati
  See the file named LICENSE for details.
*/

#include "user.h"
#include "util.h"
#include "binding.h"
#include <ruby.h>

static VALUE RubyVPI_user_require_impl(VALUE aPath)
{
    return rb_require((char*)aPath);
}

static VALUE RubyVPI_user_require(char* aPath)
{
    int error = 0;
    VALUE result = rb_protect(RubyVPI_user_require_impl, (VALUE)aPath, &error);

    if (error)
    {
        RubyVPI_util_error("rb_require('%s') failed with status %d", aPath, error);
    }

    return result;
}

///
/// Body of the ruby thread which runs the user code.
///
static VALUE RubyVPI_user_body(char* aUserScript)
{
    RubyVPI_util_debug("Ruby: BEGIN synchronized with simulator");
    RubyVPI_user_require(aUserScript); // blocks until user script is finished

    RubyVPI_util_debug("Ruby: END");
    // don't wait for anyone to resume me anymore
}

static VALUE RubyVPI_user__module_RubyVPI = Qnil;
static ID RubyVPI_user__symbol_resume = 0;

void RubyVPI_user_init()
{
    // mailbox init
    RubyVPI_util_debug("User: mailbox init");
    RubyVPI_user_require("ruby-vpi/boot/relay");


    // ruby thread init
    RubyVPI_util_debug("User: ruby thread init");
    rb_thread_create(RubyVPI_user_body, "ruby-vpi/boot/loader");


    // wait for thread to pause
    RubyVPI_util_debug("User: calling RubyVPI.attach");

    RubyVPI_user__module_RubyVPI = rb_const_get(rb_cObject, rb_intern("RubyVPI"));
    rb_funcall(RubyVPI_user__module_RubyVPI, rb_intern("attach"), 0);

    RubyVPI_util_debug("User: calling RubyVPI.attach DONE");


    RubyVPI_util_debug("User: ruby thread is active & ran once");
    RubyVPI_user__symbol_resume = rb_intern("resume");
}

void RubyVPI_user_fini()
{
    RubyVPI_user__module_RubyVPI = Qnil;
    // Ruby will garbage collect everything else
}

PLI_INT32 RubyVPI_user_resume(p_cb_data aCallback)
{
    RubyVPI_util_debug("Main: callback = %p", aCallback);
    RubyVPI_util_debug("Main: callback.user_data = %p", aCallback ? aCallback->user_data : 0);

    RubyVPI_util_debug("Main: calling RubyVPI.resume");
    // pass VPI callback to user code as Ruby object
    rb_funcall(RubyVPI_user__module_RubyVPI, RubyVPI_user__symbol_resume, 1, RubyVPI_binding_rubify_callback(aCallback));

    return 0;
}
