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

# Provides configuration information of the Ruby-VPI project.
module RubyVpi
  # Initializes the current bench using the given parameters.
  def RubyVpi.init_bench aTestPrefix, aProtoClassId
    require 'ruby-vpi/vpi'
    Vpi::relay_verilog	# service the $ruby_init() callback

    # set up code coverage analysis
      unless (ENV['COVERAGE'] || '').empty?
        require 'ruby-vpi/rcov'

        RubyVpi.with_coverage_analysis do |a|
          a.dump_coverage_info [
            Rcov::TextReport.new,
            Rcov::HTMLCoverage.new(:destdir => "#{aTestPrefix}_coverage")
          ]
        end
      end

    # load the design under test
      require "#{aTestPrefix}_design.rb"

      unless (ENV['PROTOTYPE'] || '').empty?
        require "#{aTestPrefix}_proto.rb"

        proto = Kernel.const_get(aProtoClassId).new

        Vpi.class_eval do
          define_method :relay_verilog do
            proto.simulate!
          end
        end

        puts "#{aTestPrefix}: verifying prototype instead of design"
      end

    require "#{aTestPrefix}_spec.rb"
  end

  module Config
    PROJECT_ID = 'ruby-vpi'
    PROJECT_NAME = 'Ruby-VPI'
    PROJECT_URL = "http://#{PROJECT_ID}.rubyforge.org"
    PROJECT_SUMMARY = "Ruby interface to Verilog VPI."
    PROJECT_DETAIL = "#{PROJECT_NAME} is a #{PROJECT_SUMMARY}. It lets you create complex Verilog test benches easily and wholly in Ruby."

    Simulator = Struct.new(:id, :name, :compiler_args, :linker_args)
    SIMULATORS = [
      Simulator.new(:cver, 'GPL Cver', '-DPRAGMATIC_CVER', ''),
      Simulator.new(:ivl, 'Icarus Verilog', '-DICARUS_VERILOG', ''),
      Simulator.new(:vcs, 'Synopsys VCS', '-DSYNOPSYS_VCS', ''),
      Simulator.new(:vsim, 'Mentor Modelsim', '-DMENTOR_MODELSIM', ''),
    ]
  end
end
