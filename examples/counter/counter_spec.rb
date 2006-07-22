# A specification which verifies the design under test.
=begin
	Copyright 2006 Suraj N. Kurapati
	Copyright 1999 Kazuhiro HIWADA

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


require 'counter_design.rb'
require 'vpi_util'
require 'rspec'

include Vpi


# Lowest upper bound of counter's value
LIMIT = 2 ** Counter::Size

# Maximum allowed value for a counter
MAX = LIMIT - 1


context "A resetted counter" do
	setup do
		@design = Counter.new
		@design.reset!
	end

	specify "should be zero" do
		@design.count.intVal.should.be 0
	end

	specify "should increment every cycle" do
		LIMIT.times do |i|
			@design.count.intVal.should.be i

			# increment the counter
			relay_verilog
		end
	end
end

context "A counter with the maximum value" do
	setup do
		@design = Counter.new
		@design.reset!

		# increment to maximum value
		MAX.times {relay_verilog}
		@design.count.intVal.should.be MAX
	end

	specify "should overflow upon increment" do
		# increment the counter
		relay_verilog

		@design.count.intVal.should.be 0
	end
end
