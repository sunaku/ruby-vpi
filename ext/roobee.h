/*
  Copyright 2008 Suraj N. Kurapati
  See the file named LICENSE for details.
*/
///\file A proxy for all Ruby headers.

#ifndef ROOBEE_H
#define ROOBEE_H

  #include <ruby.h>

  ///
  /// Initializes the Ruby interpreter.
  ///
  /// This function must be called ONLY from the
  /// main C process (NOT from inside a thread).
  ///
  static void RubyVPI_roobee_init(char* aProgName);

  ///
  /// Cleans up the Ruby interpreter.
  ///
  /// This function must be called ONLY from the
  /// main C process (NOT from inside a thread).
  ///
  static void RubyVPI_roobee_fini();

  ///
  /// Runs the given file inside the Ruby thread.
  ///
  /// The relay module must be initialized before you call this function.
  ///
  static void RubyVPI_roobee_run(char* aFileToRun);

#endif
