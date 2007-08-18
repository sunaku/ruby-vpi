# Initializes the test bench by setting up code
# coverage, the interactive debugger, and so on:
#
# 1. loads the design.rb file
# 2. loads the proto.rb file if prototyping is enabled
# 3. loads the spec.rb file
#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

SIMULATOR     = ENV['RUBYVPI_SIMULATOR'].to_sym
designName    = ENV['RUBYVPI_BOOT_TARGET']

USE_DEBUGGER  = ENV['DEBUGGER'].to_i  == 1
USE_COVERAGE  = ENV['COVERAGE'].to_i  == 1
USE_PROTOTYPE = ENV['PROTOTYPE'].to_i == 1


require 'rubygems'
require 'ruby-vpi'
require 'ruby-vpi/util'

require 'ruby-vpi/vpi'
at_exit { Vpi::__boot__finalize }


# set up code coverage analysis
  if USE_COVERAGE
    require 'ruby-vpi/rcov'

    RubyVPI.with_coverage_analysis do |a|
      a.dump_coverage_info [
        Rcov::TextReport.new,
        Rcov::HTMLCoverage.new(:destdir => "#{designName}_coverage")
      ]
    end

    RubyVPI.say 'coverage analysis is enabled'
  end

# set up the interactive debugger
  if USE_DEBUGGER
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

# load the design under test
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
      def method_missing(*a, &b)
        @@design.__send__(*a, &b)
      end

      alias const_missing method_missing

      # pass these methods to method_missing
      undef to_s
      undef inspect
      undef type
      undef respond_to?
    end

    # make module parameters available as constants
    @@design[VpiParameter, VpiLocalParam].each do |var|
      const_set(var.name.to_ruby_const_name, var.intVal)
    end

    # methods in design.rb & proto.rb must execute on the DUT
    @@design.extend(self)
  end

  Kernel.const_set(designName.to_ruby_const_name, design)

  f = "#{designName}_design.rb"
  design.module_eval(File.read(f), f) if File.exist? f

# load the design's prototype
  if USE_PROTOTYPE
    f = "#{designName}_proto.rb"
    design.module_eval(File.read(f), f) if File.exist? f

    unless design.respond_to? :feign!
      raise NoMethodError, "handle #{design} does not have a 'feign!' method"
    end

    Vpi.module_eval do
      define_method :__proto__simulate_hardware do
        design.feign!
      end

      def vpi_register_cb #:nodoc:
        warn "vpi_register_cb: callbacks are ignored when prototype is enabled"
      end
    end

    RubyVPI.say 'prototype is enabled'
  end

# load the design's specification
  Vpi::__scheduler__start
  require "#{designName}_spec.rb"
