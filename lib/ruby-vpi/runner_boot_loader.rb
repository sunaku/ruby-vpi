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
require 'ruby-vpi/util'
require 'ruby-vpi/core'


designName = ENV['RUBYVPI_BOOT_TARGET']

# set up code coverage analysis
  if RubyVPI::USE_COVERAGE
    require 'ruby-vpi/rcov'

    RubyVPI::Coverage.attach do |analysis|
      analysis.dump_coverage_info [
        Rcov::TextReport.new,
        Rcov::HTMLCoverage.new(:destdir => "#{designName}_coverage")
      ]
    end

    RubyVPI::Coverage.start
    RubyVPI.say 'coverage analysis is enabled'
  end

# set up the interactive debugger
  if RubyVPI::USE_DEBUGGER
    require 'ruby-debug'

    Debugger.start
    Debugger.post_mortem

    RubyVPI.say 'debugger is enabled'
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

    RubyProf.start

    at_exit do
      result = RubyProf.stop
      printer = RubyProf::GraphPrinter.new(result)

      File.open("#{designName}_profile.txt", 'w') do |out|
        printer.print(out)
      end
    end

    RubyVPI.say 'bottleneck profiler is enabled'
  end

# load the design under test
  class Object
    include VPI
  end

  unless designHandle = vpi_handle_by_name(designName, nil)
    raise "cannot access the design under test: #{designName.inspect}"
  end

  # create a module to wrap the DUT, so that inner classes and modules
  # and constants defined in the design.rb and proto.rb files are
  # accessible in spec.rb through the namespace resolution operator (::)
  design = Module.new do
    @@design = designHandle

    # delegate all instance methods to the DUT
    instance_eval do
      def method_missing(*a, &b) #:nodoc:
        @@design.__send__(*a, &b)
      end

      # pass these methods to method_missing
      undef to_s
      undef inspect
      undef type
      undef respond_to?
    end

    # make module parameters available as constants
    @@design[VpiParameter, VpiLocalParam].each do |var|
      const_set(var.name.to_ruby_const_name, var.get_value(VpiIntVal))
    end

    # methods in design.rb & proto.rb must execute on the DUT
    @@design.extend(self)
  end

  Kernel.const_set(designName.to_ruby_const_name, design)

# load the user's test bench
  RubyVPI::Scheduler.start

  # design file
  f = "#{designName}_design.rb"
  design.module_eval(File.read(f), f) if File.exist? f

  # prototype file
  if RubyVPI::USE_PROTOTYPE
    f = "#{designName}_proto.rb"
    design.module_eval(File.read(f), f) if File.exist? f

    VPI.module_eval do
      def vpi_register_cb #:nodoc:
        warn "vpi_register_cb: callbacks are ignored when prototype is enabled"
      end
    end

    RubyVPI.say 'prototype is enabled'
  end

  # specification file
  require "#{designName}_spec.rb"
