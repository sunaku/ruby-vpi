/*
  Copyright 2006 Suraj N. Kurapati
  See the file named LICENSE for details.
*/

#include "main.h"
#include "util.h"
#include "roobee.h"
#include <stdio.h>
#include <stdbool.h>

// XXX: the CVER simulator has trouble with executing the
//      RubyVPI_relay_from_c_to_ruby callback handler
//      unless we lump all C code into one monolithic file
#include "roobee.cin"
#include "binding.cin"
#include "relay.cin"
#include "verilog.cin"

///
/// Returns true if the given file exists and is readable.
///
static bool RubyVPI_main_file_exists(char* aFilePath)
{
    FILE* f = fopen(aFilePath, "r");

    if (f)
    {
        fclose(f);
        return true;
    }

    return false;
}

static PLI_INT32 RubyVPI_main_init(p_cb_data aCallback)
{
    // parameters for bootstrapping the Ruby side of Ruby-VPI
    char* bootLoader = getenv("RUBYVPI_BOOT_LOADER");
    char* testLoader = getenv("RUBYVPI_TEST_LOADER");

    RubyVPI_util_debug("testLoader: '%s'", testLoader);
    RubyVPI_util_debug("bootLoader: '%s'", bootLoader);

    if (!bootLoader)
    {
        RubyVPI_util_error("environment variable RUBYVPI_BOOT_LOADER not defined");
        return;
    }

    if (!RubyVPI_main_file_exists(bootLoader))
    {
        RubyVPI_util_error("environment variable RUBYVPI_BOOT_LOADER gave nonexistent path: %s", bootLoader);
        return;
    }

    if (!testLoader)
    {
        RubyVPI_util_error("environment variable RUBYVPI_TEST_LOADER not defined");
        return;
    }

    if (!RubyVPI_main_file_exists(testLoader))
    {
        RubyVPI_util_error("environment variable RUBYVPI_TEST_LOADER gave nonexistent path: %s", testLoader);
        return;
    }

    // initialize all subsystems
    RubyVPI_util_debug("C: init Ruby interpreter");
    RubyVPI_roobee_init(testLoader);

    RubyVPI_util_debug("C: register SWIG bindings");
    RubyVPI_binding_init();

    #if defined(HAVE_RUBY_1_8) && defined(PRAGMATIC_CVER)
        // for Ruby 1.8, the relay mechanism is
        // initialized inside the body of the Ruby
        // thread (see RubyVPI_roobee_thread_body())
        // to avoid address corruption issues
    #else
        RubyVPI_util_debug("C: init relay mechanism");
        RubyVPI_relay_init();
    #endif

    // start the Ruby thread which will house the
    // execution of the user's executable specification
    RubyVPI_roobee_run(bootLoader);

    // start ruby since we're already at start of sim.
    RubyVPI_relay_from_c_to_ruby(0);
}

static PLI_INT32 RubyVPI_main_fini(p_cb_data aCallback)
{
    RubyVPI_util_debug("C: at end of simulation");

    RubyVPI_roobee_fini();

    RubyVPI_util_debug("C: exit");
}

