# Initializes the test bench by setting up code
# coverage, the interactive debugger, and so on:
#
# 1. loads the design.rb file if it exists
# 2. loads the proto.rb file if it exists and prototyping is enabled
# 3. loads the spec.rb file
#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

# return control to the simulator before Ruby exits.
# otherwise, the simulator will not have a chance to do
# any clean up or finish any pending tasks that remain
at_exit { VPI::__extension__relay_verilog unless $! }


begin
  require 'rubygems'
rescue LoadError
end

require 'ruby-vpi'
require 'ruby-vpi/core'

# copy Ruby output into simulator's log file
  [STDOUT, STDERR].each do |stream|
    class << stream #:nodoc:
      alias __write__ write

      def write aString
        s = aString.to_s

        VPI.vpi_printf(s)
        return s.length
      end
    end
  end

# set up code coverage analysis
  if RubyVPI::USE_COVERAGE
    require 'ruby-vpi/rcov'

    outFile = "coverage.txt"
    RubyVPI::Coverage.attach do |analysis|
      begin
        File.open(outFile, 'w') do |f|
          STDOUT.flush
          $stdout = f

          analysis.dump_coverage_info [
            Rcov::TextReport.new,
            Rcov::FullTextReport.new(:textmode => :counts),
          ]
        end
      ensure
        $stdout = STDOUT
      end
    end

    RubyVPI::Coverage.start
    RubyVPI.say "coverage analysis is enabled; results stored in #{outFile}"
  end

# set up the interactive debugger
  if RubyVPI::USE_DEBUGGER
    require 'ruby-debug'

    Debugger.start
    Debugger.post_mortem

    RubyVPI.say 'interactive debugger is enabled'
  end

  # suppress undefined method errors when debugger is not enabled
    unless Kernel.respond_to? :debugger
      Kernel.class_eval do
        # Starts an interactive debugging session.
        def debugger
        end
      end
    end

# set up the profiler
  if RubyVPI::USE_PROFILER
    require 'ruby-prof'

    outFile = "profile.txt"
    at_exit do
      result = RubyProf.stop
      printer = RubyProf::GraphPrinter.new(result)

      File.open(outFile, 'w') do |out|
        printer.print(out)
      end
    end

    RubyProf.start
    RubyVPI.say "performance analysis is enabled; results stored in #{outFile}"
  end

# set up the prototyping environment
  if RubyVPI::USE_PROTOTYPE
    VPI.module_eval do
      def vpi_register_cb *args #:nodoc:
        warn "vpi_register_cb: callbacks are ignored when prototype is enabled"
      end
    end

    RubyVPI.say 'prototype is enabled'
  end

# make VPI functions available globally
  class Object
    include VPI
  end

# load the user-defined test loader
  RubyVPI::Scheduler.start
  require $0
