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
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

// The whole Ruby-VPI code is bootstrapped from this file. So, the intent is that a verilog testbench invokes the Ruby VPI extension, which in turn performs some extra things for us.
module test;

	reg clk_reg;
	reg rst_reg;
	wire [4:0] count;

	initial begin
		#0 clk_reg = 0; rst_reg = 1;
		#1 rst_reg = 0;

		$ruby_init("-w", "test.rb");

		#0 $display($time); $ruby_relay();
		#10 $display($time); $ruby_relay();
		#10 $display($time); $ruby_relay();
		#10 $display($time); $ruby_relay();
		#10 $display($time); $ruby_relay();
		#10 $display($time); $ruby_relay();

		#10 $display($time);
			$ruby_task("hello");
			$ruby_task("hello", "world");
			$ruby_task("hello", 3, "foo", "baz", 5, "moz");
			$ruby_task("bogus task");
			$ruby_task();

			$ruby_init("-w", "test.rb");
		// #50 $ruby_task("hello", c1, c1.clk, c1.count);
		$finish;
	end

	always begin
		#1 clk_reg = !clk_reg;
		$display("clk_reg = %d", clk_reg);
		$display("test.c1.clk = %d", test.c1.clock);
		$display("test.c1.count = %d", test.c1.count);
	end

	counter c1(.clock(clk_reg), .reset(rst_reg), .count(count));
endmodule


