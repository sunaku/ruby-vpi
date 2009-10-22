//
// Copyright protects this work.
// See LICENSE file for details.
//

#include <stdlib.h>
#include <ruby.h>
#include "util.h"
#include "ruby.h0"
#include "binding.h"

//
// The code inside the following #ifdef block originated from:
// http://svn.ruby-lang.org/cgi-bin/viewvc.cgi/tags/v1_8_6/main.c?view=co
//
// It is Copyright (C) 1993-2003 Yukihiro Matsumoto
// and is released under the same license as Ruby.
//
#ifdef HAVE_RUBY_1_8
    #ifdef __human68k__
    int _stacksize = 262144;
    #endif

    #if defined __MINGW32__
    int _CRT_glob = 0;
    #endif

    #if defined(__MACOS__) && defined(__MWERKS__)
    #include <console.h>
    #endif

    /* to link startup code with ObjC support */
    #if (defined(__APPLE__) || defined(__NeXT__)) && defined(__MACH__)
    static void objcdummyfunction( void ) { objc_msgSend(); }
    #endif
#endif

//
// The code inside the following #ifdef block originated from:
// http://svn.ruby-lang.org/cgi-bin/viewvc.cgi/tags/v1_9_1/main.c?view=co
//
// It is Copyright (C) 1993-2003 Yukihiro Matsumoto
// and is released under the same license as Ruby.
//
#ifdef HAVE_RUBY_1_9
    RUBY_GLOBAL_SETUP
#endif

int RubyVPI_ruby_run()
{
    RubyVPI_util_debug("init");

    int argc = 4;
    char* argv[] = {"-rubygems", "-rruby-vpi/boot/loader", "-e", "p 1234567"};
    int exit_status = 0;

    //
    // The code inside the following #ifdef block originated from:
    // http://svn.ruby-lang.org/cgi-bin/viewvc.cgi/tags/v1_8_6/main.c?view=co
    //
    // It is Copyright (C) 1993-2003 Yukihiro Matsumoto
    // and is released under the same license as Ruby.
    //
    #ifdef HAVE_RUBY_1_8
        #ifdef _WIN32
            NtInitialize(&argc, &argv);
        #endif
        #if defined(__MACOS__) && defined(__MWERKS__)
            argc = ccommand(&argv);
        #endif
        {
            #ifdef RUBY_INIT_STACK
                RUBY_INIT_STACK
            #endif
            ruby_init();

            // install Ruby bindings for Verilog VPI
            RubyVPI_util_debug("VPI binding init");
            RubyVPI_binding_init();

            RubyVPI_util_debug("ruby run");
            ruby_options(argc, argv);
            ruby_run();
        }
    #endif

    //
    // The code inside the following #ifdef block originated from:
    // http://svn.ruby-lang.org/cgi-bin/viewvc.cgi/tags/v1_9_1/main.c?view=co
    //
    // It is Copyright (C) 1993-2003 Yukihiro Matsumoto
    // and is released under the same license as Ruby.
    //
    #ifdef HAVE_RUBY_1_9
        ruby_sysinit(&argc, &argv);
        {
            RUBY_INIT_STACK;
            ruby_init();

            // install Ruby bindings for Verilog VPI
            RubyVPI_util_debug("VPI binding init");
            RubyVPI_binding_init();

            RubyVPI_util_debug("ruby run");
            exit_status = ruby_run_node(ruby_options(argc, argv));
        }
    #endif

    return exit_status;
}
