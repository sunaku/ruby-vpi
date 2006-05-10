/*
	Copyright 2006 Suraj N. Kurapati
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

// Note: DUT means "design under test"

// The whole Ruby-VPI code is bootstrapped from this file. So, the intent is that a verilog testbench invokes the Ruby VPI extension, which in turn performs some extra things for us.
module counter_tb;

	reg clk;
	reg reset;
	wire [4:0] count;


	initial begin
		#0 $ruby_init("-w", "counter_tb.rb");
		#1 clk = 0; reset = 0;
	end


	// generate a 50% duty-cycle clock for the DUT
	always begin
		#5 clk = ~clk;
	end


	// transfer control to Ruby-VPI every clock cycle
	always @(posedge clk) begin
		$ruby_relay();
	end


	// instantiate the DUT
	counter dut(
		.clock(clk)
		, .reset(reset)

		, .count(count)
	);

endmodule
