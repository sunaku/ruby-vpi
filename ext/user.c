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

    VALUE target = rb_const_get(rb_cObject, rb_intern("RubyVPI"));
    ID method = rb_intern("attach");
    rb_funcall(target, method, 0);

    RubyVPI_util_debug("User: calling RubyVPI.attach DONE");


    RubyVPI_util_debug("User: ruby thread is active & ran once");
}

void RubyVPI_user_fini()
{
    // nothing to clean up; Ruby will garbage collect everything
}

PLI_INT32 RubyVPI_user_resume(p_cb_data aCallback)
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

    RubyVPI_util_debug("Main: ruby callback for %p =>", aCallback);
    VALUE call = RubyVPI_binding_rubify_callback(aCallback);

    VALUE target = rb_const_get(rb_cObject, rb_intern("RubyVPI"));
    ID method = rb_intern("resume");

    RubyVPI_util_debug("Main: calling RubyVPI.resume");
    rb_funcall(target, method, 1, call); // pass callback to user code

    return 0;
}
