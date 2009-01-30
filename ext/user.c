/*
  Copyright 2008 Suraj N. Kurapati
  See the file named LICENSE for details.
*/

#include "user.h"
#include "util.h"
#include "binding.h"
#include <ruby.h>
#include <assert.h>

static VALUE RubyVPI_user__relay_callcc = Qnil;
static VALUE RubyVPI_user__relay_reason = Qnil;

static VALUE RubyVPI_user_start()
{
    RubyVPI_util_debug("User: starting Ruby boot loader");

    rb_require("ruby-vpi/boot/loader");

    return Qnil;
}

static VALUE RubyVPI_user_continue()
{
    // resume the continuation and pass the callback as its return value
    rb_funcall(RubyVPI_user__relay_callcc, rb_intern("call"), 1, RubyVPI_user__relay_reason);

    return Qnil;
}

static void RubyVPI_user_catch_callcc(VALUE (*func)())
{
    RubyVPI_user__relay_callcc = rb_catch("RubyVPI_relay_verilog", func, Qnil);

    RubyVPI_util_debug("User: caught callcc thrown by Ruby: %s",
        RSTRING(
            rb_funcall(RubyVPI_user__relay_callcc, rb_intern("inspect"), 0)
        )->ptr
    );
}

void RubyVPI_user_init()
{
    RubyVPI_user_catch_callcc(RubyVPI_user_start);
}

PLI_INT32 RubyVPI_user_resume(p_cb_data aCallback)
{
    RubyVPI_util_debug("User: resuming Ruby due to callback %p", aCallback);

    RubyVPI_user__relay_reason = RubyVPI_binding_rubify_callback(aCallback);
    RubyVPI_user_catch_callcc(RubyVPI_user_continue);

    return 0;
}

void RubyVPI_user_fini()
{
    // nothing to do
}
