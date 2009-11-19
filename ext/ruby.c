//
// Copyright protects this work.
// See LICENSE file for details.
//

#include <stdlib.h>
#include <stdio.h>
#include <ruby.h>
#include "ruby.h0"
#include "binding.h"

static VALUE RubyVPI_ruby_require(const char* file)
{
    VALUE result;
    int error;

    result = rb_protect((VALUE (*)(VALUE))rb_require, (VALUE)file, &error);
    if (error)
    {
        fprintf(stderr,
            "rb_require('%s') failed with status=%d\n", file, error);

        VALUE exception = rb_gv_get("$!");
        if (RTEST(exception))
        {
            fprintf(stderr, "... because an exception was raised:\n");
            fflush(stderr);

            VALUE inspect = rb_inspect(exception);
            rb_io_puts(1, &inspect, rb_stderr);

            VALUE backtrace = rb_funcall(
                exception, rb_intern("backtrace"), 0);
            rb_io_puts(1, &backtrace, rb_stderr);
        }
    }

    return result;
}

void RubyVPI_ruby_body(void* stack_lower_bound, void* stack_upper_bound, const char* file)
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
        RubyVPI_ruby_require(file);
        printf("Ruby: require 'hello' end\n");

        ruby_cleanup(0);
    }

    printf("Context: Ruby end\n");

    printf("Context: end\n");

    ruby_context_finished = true;
    relay_from_ruby_to_main(Qnil);
}
