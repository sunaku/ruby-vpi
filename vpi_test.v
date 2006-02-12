/*
	Copyright 2006 Suraj Kurapati
	Copyright 1999 Kazuhiro HIWADA

	This file is part of Ruby-VPI.

	Ruby-VPI is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	Ruby-VPI is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA	 02110-1301	 USA
*/

// The whole VPI code is bootstrapped from this file. So, the intent is that a verilog testbench invokes the Ruby VPI extension, which in turn performs some extra things for us.
module test;
	reg a;
	initial begin
		$ruby_init("-w", "vpi_test.rb");
		#0 $display($time); $ruby_callback();
		#10 $display($time); $ruby_callback();
		#10 $display($time); $ruby_callback();
		#10 $display($time); $ruby_callback();
		#10 $display($time); $ruby_callback();
		#10 $display($time); $ruby_callback();

		// #20 $hello_world(); // TODO: find solution to this.. Icarus Verilog is unable to find the systf definition for the C function associated with this call at compile time (when Ruby has not even been run, to bind a systf for this call, yet!)
	end
endmodule
