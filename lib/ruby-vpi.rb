# General Ruby-VPI project information and testbench bootstrapping.
#--
# Copyright 2006-2007 Suraj N. Kurapati
# See the file named LICENSE for details.

module RubyVpi
  # Initializes the bench by setting up code coverage, the interactive debugger,
  # and so on:
  #
  # 1. loads the design.rb file
  # 2. loads the proto.rb file if prototyping is enabled
  # 3. loads the spec.rb file
  #
  # aDesignId:: The name of the Ruby object which gives access to the design
  #             under test.
  #
  # aSpecFormat:: The name of the format being used by the specification.
  #
  # aSimulationCycle::  A block that simulates the design under test by, for
  #                     example, toggling the clock signal.
  #
  def RubyVpi.init_bench aDesignId, aSpecFormat, &aSimulationCycle
    raise ArgumentError, "block must be given" unless block_given?

    if caller.find {|s| s =~ /^(.*?)_bench.rb:/}
      testName = $1
    else
      raise 'Unable to determine name of test.'
    end

    useDebugger  = ENV['DEBUG'].to_i     == 1
    useCoverage  = ENV['COVERAGE'].to_i  == 1
    usePrototype = ENV['PROTOTYPE'].to_i == 1

    # set up code coverage analysis
      # XXX: this is loaded *before* RCov to prevent coverage statistics about
      # it
      require 'ruby-vpi/vpi'

      if useCoverage
        require 'ruby-vpi/rcov'

        RubyVpi.with_coverage_analysis do |a|
          a.dump_coverage_info [
            Rcov::TextReport.new,
            Rcov::HTMLCoverage.new(:destdir => "#{testName}_coverage")
          ]
        end

        Vpi::vpi_printf "#{Config::PROJECT_NAME}: coverage analysis is enabled for test #{testName.inspect}\n"
      end

    # set up the specification library
      case aSpecFormat
        when :xUnit
          require 'test/unit'

        when :rSpec
          ARGV.concat %w[-f s]
          require 'spec'

        when :tSpec
          ARGV << '-rs'
          require 'test/spec'
      end

    # set up the interactive debugger
      if useDebugger
        require 'ruby-debug'

        Debugger.start
        Debugger.post_mortem

        Vpi::vpi_printf "#{Config::PROJECT_NAME}: debugger is enabled for test #{testName.inspect}\n"
      end

      # suppress undefined method errors when debugger is not enabled
        unless Kernel.respond_to? :debugger
          Kernel.class_eval do
            define_method :debugger do
              # this is a dummy method!
            end
          end
        end

    # set up the VPI utility layer
      Object.class_eval do
        include Vpi
      end

      Vpi.module_eval do
        @@simCycle = aSimulationCycle

        # Simulates the design under test for the given number of cycles.
        def simulate aNumCycles = 1
          aNumCycles.times {@@simCycle.call}
        end
      end

    # load the design under test
      unless design = vpi_handle_by_name("#{testName}_bench", nil)
        raise "Verilog bench for test #{testName.inspect} is inaccessible."
      end

      Kernel.const_set(aDesignId, design)
      require "#{testName}_design.rb"

    # load the design's prototype
      if usePrototype
        require "#{testName}_proto.rb"

        Vpi.module_eval do
          define_method :advance_time do |*args|
            Integer(args.first || 1).times { design.simulate! }
          end

          define_method :vpi_register_cb do
            warn "vpi_register_cb: callbacks are ignored when prototype is enabled"
          end
        end

        Vpi::vpi_printf "#{Config::PROJECT_NAME}: prototype is enabled for test #{testName.inspect}\n"

      else
        # XXX: this completes the handshake, by calling relay_verilog, with
        # pthread_mutex_lock() in relay_main() in the C extension
        advance_time
      end

    # load the design's specification
      require "#{testName}_spec.rb"
  end

  # Provides information about this project's configuration.
  module Config
    PROJECT_ID = 'ruby-vpi'
    PROJECT_NAME = 'Ruby-VPI'
    PROJECT_URL = "http://#{PROJECT_ID}.rubyforge.org"
    WEBSITE_URL = PROJECT_URL + "/doc"
    PROJECT_SUMMARY = "Ruby interface to IEEE 1364-2005 Verilog VPI"
    PROJECT_DETAIL = "#{PROJECT_NAME} is a #{PROJECT_SUMMARY} and a platform for unit testing, rapid prototyping, and systems integration of Verilog modules through Ruby. It lets you create complex Verilog test benches easily and wholly in Ruby."

    Simulator = Struct.new(:name, :compiler_args, :linker_args)

    # List of supported Verilog simulators.
    SIMULATORS = {
      :cver   => Simulator.new('GPL Cver',        '-DPRAGMATIC_CVER',   ''),
      :ivl    => Simulator.new('Icarus Verilog',  '-DICARUS_VERILOG',   ''),
      :vcs    => Simulator.new('Synopsys VCS',    '-DSYNOPSYS_VCS',     ''),
      :vsim   => Simulator.new('Mentor Modelsim', '-DMENTOR_MODELSIM',  ''),
      :ncsim  => Simulator.new('Cadence NC-Sim',  '-DCADENCE_NCSIM',    ''),
    }
  end
end
