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

puts "ruby:check 0, $ruby_init();"

h = VPI::Handle.new
h2 = h.dup
puts "Handle.new is #{h.inspect}"
puts "Handle.new.dup is #{h2.inspect}"
h == h2	# TODO: add equals checking (unwrapped should be same for them to be equal, no?)

VPI::register_task("hello") { |*a| puts "hello #{ a.join(', ') }" }
VPI::relay_verilog

puts "ruby:check 1, $ruby_relay();"
VPI::relay_verilog

puts "ruby:check 2, $ruby_relay();"
VPI::relay_verilog

puts "ruby:check 3, $ruby_relay();"
VPI::relay_verilog

puts "ruby:check 4, $ruby_relay();"
VPI::relay_verilog

puts "ruby:check 5, $ruby_relay();"
VPI::relay_verilog
