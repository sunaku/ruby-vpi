=begin
	Copyright 2006 Suraj N. Kurapati
	Copyright 1999 Kazuhiro HIWADA

	This file is part of Ruby-VPI.

	Ruby-VPI is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

	Ruby-VPI is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
=end

require 'vpi_util'
require 'rspec'

# An interface to the design under test.
class Counter
	BITS = 5
	LIMIT = 2 ** BITS
	MAX = LIMIT - 1


	attr_reader :clock, :reset, :count

	def initialize
		@clock = Vpi::vpi_handle_by_name("counter_tb.clock", nil)
		@reset = Vpi::vpi_handle_by_name("counter_tb.reset", nil)
		@count = Vpi::vpi_handle_by_name("counter_tb.count", nil)
	end
end

# verify the design
include Vpi

	# resets the given design
	def reset aDesign
		aDesign.reset.intVal = 1
		3.times {relay_verilog}
		aDesign.reset.intVal = 0

		@design.count.intVal.should.be 0
	end

context "A resetted Counter" do
	setup do
		@design = Counter.new

		# reset the counter
		reset @design
	end

	specify "should be zero" do
		@design.count.intVal.should.be 0
		relay_verilog
	end

	specify "should increment every cycle" do
		Counter::LIMIT.times do |i|
			@design.count.intVal.should.be i
			relay_verilog
		end
	end
end

context "A counter with the maximum value" do
	setup do
		@design = Counter.new

		# reset the counter
		reset @design

		# increment to maximum value
		0.upto(Counter::MAX) {relay_verilog}
		@design.count.intVal.should.be Counter::MAX
	end

	specify "should overflow upon increment" do
		# increment the counter
		relay_verilog

		@design.count.intVal.should.be 0
		relay_verilog
	end
end


# bootstrap this file
if $0 == __FILE__
	# service the $ruby_init() callback
	Vpi::relay_verilog

	# service the $ruby_relay() callback
	# RSpec will take control from here.
end
