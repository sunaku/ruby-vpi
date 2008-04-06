/*
  Copyright 2006 Suraj N. Kurapati
  See the file named LICENSE for details.
*/
///\file Utility functions.

#ifndef UTIL_H
#define UTIL_H

    #include "verilog.h"

    /// An alias for vpi_printf().
    ///
    /// @param	...	Arguments to vpi_printf()
    ///
    #define RubyVPI_util_write vpi_printf

    /// Marks the given message as being emitted from Ruby-VPI and prints it.
    ///
    /// @param	...	Arguments to vpi_printf()
    ///
    #define RubyVPI_util_print(...) \
        RubyVPI_util_write("[%s:%d] Ruby-VPI: ", __FILE__, __LINE__); \
        RubyVPI_util_write(__VA_ARGS__);

    /// Marks the given message as being emitted from Ruby-VPI
    /// and prints it while ending the message with a new line.
    ///
    /// @param	...	Arguments to RubyVPI_util_write()
    ///
    #define RubyVPI_util_puts(...) \
        RubyVPI_util_print(__VA_ARGS__); \
        RubyVPI_util_write("\n");

    /// Marks the given message as being being an
    /// error message from Ruby-VPI and prints it
    /// while ending the message with a new line
    /// and then stopping the simulation.
    ///
    /// @param	...	Arguments to RubyVPI_util_write()
    ///
    #define RubyVPI_util_error(...) \
        RubyVPI_util_puts("error: " __VA_ARGS__); \
        vpi_control(vpiStop);

    /// A wrapper for RubyVPI_util_puts() which marks
    /// the given message as being debugging output.
    ///
    #ifdef DEBUG
        #define RubyVPI_util_debug RubyVPI_util_puts
    #else
        #define RubyVPI_util_debug(...)
    #endif

#endif
