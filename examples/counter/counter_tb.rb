=begin
	Copyright 2006 Suraj Kurapati
	Copyright 1999 Kazuhiro HIWADA

	This file is part of Ruby-VPI.

	Ruby-VPI is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	Ruby-VPI is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
=end

# Note: DUT means "design under test"

require 'vpi_util'
require 'test/unit'


class TestCounter < Test::Unit::TestCase
	include Vpi

	# Number of bits used in the counter.
	COUNTER_BITS = 5
	COUNTER_LIMIT = 2 ** COUNTER_BITS

	# Number of cycles needed to reset the DUT
	DUT_RESET_DELAY = 5


	def setup
		# get handles to simulation objects
		@dut_clock = vpi_handle_by_name("counter_tb.clock", nil)
		@dut_reset = vpi_handle_by_name("counter_tb.reset", nil)
		@dut_count = vpi_handle_by_name("counter_tb.count", nil)


		# reset the DUT
		@dut_reset.value = 1
		DUT_RESET_DELAY.times {relay_verilog}

		@dut_reset.value = 0
		puts "DUT has been reset"
	end

	def test_count
		COUNTER_LIMIT.times do |i|
			assert_equal i, @dut_count.value

			# increment the counter
			relay_verilog
		end

		assert_equal 0, @dut_count.value, "counter should overflow"
	end
end


# $ruby_init():
Vpi::relay_verilog


# $ruby_relay():
# do nothing here, because test/unit will automatically run the unit test above
