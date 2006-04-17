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

puts "start of #{__FILE__}"

require 'VPI'

# handle the $ruby_init() task
puts "inside $ruby_init"

	# test VPI::handle
	begin
		h1 = VPI::Handle.new
		h2 = h1.dup
		raise unless h1 == h2
	end


	# test VPI::handle_by_name
	begin
		VPI::handle_by_name("", 0)
	rescue TypeError
	else
		raise "parent must be a Handle"
	end

VPI::relay_verilog



# handle the $ruby_relay() task
100.times do |i|
	puts "#{i}: inside $relay_ruby"

		# test getting and setting of 1-bit register or wire
		if i == 5
			c1_clock = VPI::handle_by_name("test.c1.clock")
			puts c1_clock.value

			c1_clock.value = 0
			puts c1_clock.value

			clk_reg = VPI::handle_by_name("test.clk_reg")
			p clk_reg.value

			raise unless clk_reg == c1_clock
		end


		# test resetting of counter
		if i == 10
			reset = VPI::handle_by_name("test.c1.reset")

			puts "resetting counter"
			reset.value = 1
		end


		# test simulator control functions
		VPI::stop if i == 15
		VPI::finish if i == 20

	# transfer control back to Verilog code
	VPI::relay_verilog
end


puts "end of #{__FILE__}"
