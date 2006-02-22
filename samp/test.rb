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



puts "ruby:check 0, $ruby_init();"
	VPI::register_task("hello") { |*a| puts "hello #{ a.join(', ') }" }

=begin
	if !defined? x
		VPI::reset
		x = 0
	end
=end
VPI::relay_verilog


puts "ruby:check 1, $ruby_relay();"
	c1_clock = VPI::handle_by_name("test.c1.clock", nil)
	puts c1_clock.value
	c1_clock.value = 0
	puts c1_clock.value

	clk_reg = VPI::handle_by_name("test.clk_reg", nil)
	p clk_reg.value

	raise unless clk_reg == c1_clock
VPI::relay_verilog


puts "ruby:check 2, $ruby_relay();"
VPI::relay_verilog


puts "ruby:check 3, $ruby_relay();"
VPI::relay_verilog


puts "ruby:check 4, $ruby_relay();"
VPI::relay_verilog

puts "ruby:check 5, $ruby_relay();"
	count = VPI::handle_by_name("test.c1.count", nil)
	p count.value

	count.value = 5
	p count.value
VPI::relay_verilog
