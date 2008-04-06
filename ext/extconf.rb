# Generates a makefile for buiding the extension.
#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

require 'mkmf'

# check for ruby library
  require 'rbconfig'

  # possible names under which Ruby library is installed
  rubyLibNames = Config::CONFIG.values.join(' ').
                 scan(/-l(ruby\S*)/).flatten.uniq

  # possible places where Ruby library is installed
  rubyLibPaths = Config::CONFIG.values.join(' ').
                 scan(/-L(\S+)/).flatten.
                 select {|f| File.exist? f }

  p :rubyLibNames => rubyLibNames
  p :rubyLibPaths => rubyLibPaths


  RUBY_FUNC = 'ruby_init'

  hasRuby = rubyLibNames.any? do |libName|
    have_library(libName, RUBY_FUNC) or

    rubyLibPaths.any? do |libPath|
      have_library(libName, RUBY_FUNC, libPath)
    end
  end

  p :hasRuby => hasRuby

# create the makefile
hasRuby && create_makefile('ruby-vpi')
