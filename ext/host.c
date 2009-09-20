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

PLI_INT32 RubyVPI_host_init(p_cb_data aCallback)
{
    //
    // ruby init
    //

    int argc = 0;
    char** argv = {""};
    RubyVPI_util_debug("Host: ruby_sysinit(%d, %p)", argc, argv);
    ruby_sysinit(&argc, &argv);

    VALUE dummy;
    VALUE* stack_start = &dummy + 0x1000;
    RubyVPI_util_debug("Host: ruby_init_stack(%p)", stack_start);
    ruby_init_stack(stack_start);

    RubyVPI_util_debug("Host: ruby_init()");
    ruby_init();

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

    return 0;
}

PLI_INT32 RubyVPI_host_fini(p_cb_data aCallback)
{
    RubyVPI_util_debug("Host: user fini");
    RubyVPI_user_fini();

    RubyVPI_util_debug("Host: ruby_cleanup()");
    ruby_cleanup(0);

    return 0;
}
