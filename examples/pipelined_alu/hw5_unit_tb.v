/*
	Copyright 2006 Suraj Kurapati

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


`define WIDTH 32
`define DATABITS 7
`define OP_NOP 0
`define OP_ADD 1
`define OP_SUB 2
`define OP_MULT 3


module hw5_unit_tb;

	reg clk;
	reg reset;
	reg [`DATABITS-1:0] in_tag;
	reg [`WIDTH-1:0] in_arg1;
	reg [`WIDTH-1:0] in_arg2;
	reg [1:0] in_type;

	wire [`WIDTH-1:0] out_result;
	wire [`DATABITS-1:0] out_tag;
	wire [1:0] out_type;


	initial begin
		#0 $ruby_init("-w", "hw5_unit_tb.rb");
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
	hw5_unit dut(
		.clk(clk)
		, .reset(reset)

		, .in_databits(in_tag)
		, .a(in_arg1)
		, .b(in_arg2)
		, .in_op(in_type)

		, .res(out_result)
		, .out_databits(out_tag)
		, .out_op(out_type)
	);

endmodule