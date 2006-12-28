=begin
  Copyright 2006 Suraj N. Kurapati

  This file is part of Ruby-VPI.

  Ruby-VPI is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  Ruby-VPI is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Ruby-VPI; if not, write to the Free Software Foundation,
  Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
=end

module RubyVpi
  # Initializes the bench by loading:
  # 1. the design.rb file
  # 2. the proto.rb file if prototyping is enabled
  # 3. the spec.rb file
  #
  # aDesignId:: The name of the Ruby design object.
  # aSpecFormat:: The format being used by the specification.
  # aClockTrigger:: When the return value of this block is +true+, then the relay_verilog method returns. This block is given one argument: a handle to the clock signal that drives the design under test. If this block is not specified, relay_verilog will always return upon the next positive edge of the clock signal.
  #
  #   # return upon positive edge
  #   RubyVpi.init_bench ... |clk|
  #     clk.intVal == 1
  #   end
  #
  #   # return upon negative edge
  #   RubyVpi.init_bench ... do |clk|
  #     clk.intVal == 0
  #   end
  #
  #   # return whenever clock changes
  #   RubyVpi.init_bench ... do |clk|
  #     true
  #   end
  #
  def RubyVpi.init_bench aDesignId, aSpecFormat, &aClockTrigger # :yields: clock_signal
    if caller.find {|s| s =~ /^(.*?)_bench.rb:/}
      testName = $1
    else
      raise 'Unable to determine name of test.'
    end

    aClockTrigger ||= lambda {|clk| clk.intVal == 1}

    useDebugger = !(ENV['DEBUG'] || '').empty?
    useCoverage = !(ENV['COVERAGE'] || '').empty?
    usePrototype = !(ENV['PROTOTYPE'] || '').empty?

    # set up code coverage analysis
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
      require 'ruby-vpi/vpi'

      Object.class_eval do
        include Vpi
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
          def relay_verilog # :nodoc:
            design.simulate!
          end
        end

        Vpi::vpi_printf "#{Config::PROJECT_NAME}: prototype is enabled for test #{testName.inspect}\n"

    # trigger relay_verilog according to aClockTrigger
      else
        clock = design[VpiReg].first

        Vpi.module_eval do
          # register callback for relay_verilog
            time = S_vpi_time.new
            time.type = VpiSuppressTime

            value = S_vpi_value.new
            value.format = VpiSuppressVal

            alarm = S_cb_data.new
            alarm.reason = CbValueChange
            alarm.cb_rtn = Vlog_relay_ruby
            alarm.obj = clock
            alarm.time = time
            alarm.value = value
            alarm.index = 0
            alarm.user_data = nil

            vpi_free_object(vpi_register_cb(alarm))

          alias_method :relay_verilog_old, :relay_verilog

          define_method :relay_verilog do
            begin
              relay_verilog_old
            end until aClockTrigger.call(clock)
          end
        end

        # XXX: this completes the handshake with pthread_mutex_lock() in relay_main() in the C extension
        Vpi::relay_verilog
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
    PROJECT_DETAIL = "#{PROJECT_NAME} is a #{PROJECT_SUMMARY}. It lets you create complex Verilog test benches easily and wholly in Ruby."

    Simulator = Struct.new(:id, :name, :compiler_args, :linker_args)

    # List of supported Verilog simulators.
    SIMULATORS = [
      Simulator.new(:cver, 'GPL Cver', '-DPRAGMATIC_CVER', ''),
      Simulator.new(:ivl, 'Icarus Verilog', '-DICARUS_VERILOG', ''),
      Simulator.new(:vcs, 'Synopsys VCS', '-DSYNOPSYS_VCS', ''),
      Simulator.new(:vsim, 'Mentor Modelsim', '-DMENTOR_MODELSIM', ''),
    ]
  end
end
