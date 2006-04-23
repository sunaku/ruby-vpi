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

require 'vpi'

# handle the $ruby_init() task
puts "inside $ruby_init"
Vpi::relay_verilog


# handle the $ruby_relay() task
class TestCounter
	include Vpi

	def run
		100.times do |i|
			puts "#{i}: inside $relay_ruby"

				# test getting and setting of 1-bit register or wire
				if i == 5
					c1_clock = vpi_handle_by_name("test.c1.clock", nil)
					puts c1_clock.value

					c1_clock.value = 0
					puts c1_clock.value

					clk_reg = vpi_handle_by_name("test.clk_reg", nil)
					puts clk_reg.value
				end


				# test resetting of counter
				if i == 10
					reset = vpi_handle_by_name("test.c1.reset", nil)

					puts "resetting counter"
					reset.value = 1
				end


				# test simulator control functions
				if i == 15
					if Time.now.sec > 30
						vpi_control(VpiStop)
					else
						vpi_control(VpiFinish)
					end
				end

			# transfer control back to Verilog code
			relay_verilog
		end
	end
end

TestCounter.new.run
