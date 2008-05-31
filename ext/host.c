/*
  Copyright 2008 Suraj N. Kurapati
  See the file named LICENSE for details.
*/

#include "host.h"
#include "util.h"
#include "user.h"
#include "binding.h"
#include <ruby.h>
#include <stdlib.h>

VALUE RubyVPI_host_gProgName;

#ifdef RUBY_GLOBAL_SETUP
RUBY_GLOBAL_SETUP
#endif

PLI_INT32 RubyVPI_host_init(p_cb_data aCallback)
{
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
    RubyVPI_host_gProgName = rb_str_new2("ruby-vpi");
    rb_define_variable("$0", &RubyVPI_host_gProgName);
    rb_define_variable("$PROGRAM_NAME", &RubyVPI_host_gProgName);

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
}

PLI_INT32 RubyVPI_host_fini(p_cb_data aCallback)
{
    RubyVPI_util_debug("Host: user fini");
    RubyVPI_user_fini();

    RubyVPI_util_debug("Host: ruby_finalize()");
    ruby_finalize();
}
