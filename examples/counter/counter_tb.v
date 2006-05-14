/*
	Copyright 2006 Suraj N. Kurapati
	Copyright 1999 Kazuhiro HIWADA

	This file is part of Ruby-VPI.

	Ruby-VPI is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

	Ruby-VPI is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

module counter_tb;

	/* configuration for the DUT */
	parameter Size = 5;


	/* accessors for the DUT */
	reg clock	;
reg reset	;
wire  [Size - 1:0] count;


	/* instantiate the DUT */
	counter #(.Size(Size)) counter_tb_dut (.clock(clock), .reset(reset), .count(count));


	/* interface to Ruby-VPI */
	initial begin
		clock = 0;
		$ruby_init("-w", "counter_tb.rb", "-f", "s");
	end

	/* generate a 50% duty-cycle clock for the DUT */
	always begin
		#5 clock = ~clock;
	end

	/* transfer control to Ruby-VPI every clock cycle */
	always @(posedge clock) begin
		$ruby_relay();
	end

endmodule
