# Generates a makefile for buiding the C extension.
#
# = Environment variables
#
# CFLAGS_EXTRA  :: Provide additional options for the compiler.
# LDFLAGS_EXTRA :: Provide additional options for the linker.
#
#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

require 'mkmf'

# check for ruby library
  require 'rbconfig'

  p RUBY_DESCRIPTION

  # possible names under which Ruby library is installed
  p rubyLibNames = Config::CONFIG.values.join(' ').
    scan(/-l(ruby\S*)/).flatten.uniq.reverse

  # possible places where Ruby library is installed
  p rubyLibPaths = Config::CONFIG.values.join(' ').
                 scan(/-L(\S+)/).flatten.
                 select {|f| File.exist? f }

  RUBY_FUNC = 'ruby_init'

  hasRuby = rubyLibNames.any? do |libName|
    have_library(libName, RUBY_FUNC) or

    rubyLibPaths.any? do |libPath|
      have_library(libName, RUBY_FUNC, libPath)
    end
  end

# generate the makefile
if hasRuby and have_library('pcl', 'co_create') and have_header('sys/ucontext.h')
  # apply additional arguments for compiler and linker
  if flags = ENV['CFLAGS_EXTRA']
    $CFLAGS << " #{flags}"
  end

  if flags = ENV['LDFLAGS_EXTRA']
    $LDFLAGS << " #{flags}"
  end

  $CFLAGS << ' -Wall'

  # disable optimization when debugging
  $CFLAGS << ' -g -O0' if $CFLAGS =~ /-DDEBUG\b/

  # detect ruby version on behalf of C extension
  v = RUBY_VERSION.split('.')
  until v.empty?
    $CFLAGS << " -DHAVE_RUBY_#{v.join '_'}"
    v.pop
  end

  create_makefile 'ruby-vpi'
end
