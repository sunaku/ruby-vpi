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
module RubyVPI
  # Initializes the current bench using the given parameters.
  def RubyVPI.init_bench aTestPrefix, aProtoClassId
    require 'ruby-vpi/vpi_util'
    Vpi::relay_verilog	# service the $ruby_init() callback

    # set up code coverage analysis
      if ENV['COVERAGE']
        require 'ruby-vpi/rcov'

        RubyVPI.with_coverage_analysis do |a|
          a.dump_coverage_info [
            Rcov::TextReport.new,
            Rcov::HTMLCoverage.new(:destdir => "#{aTestPrefix}_coverage")
          ]
        end
      end

    # load the design under test
      require "#{aTestPrefix}_design.rb"

      if ENV['PROTO']
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
end
