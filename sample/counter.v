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

/**
	A 5-bit counter with asynchronous reset.
*/
module counter(
	input clock
	, input reset
	, output reg [4:0] count
);

	reg [4:0] value;

	always @(*) begin
		if(reset)
			value <= 0;
	end

	always @(posedge clock) begin
		value <= value + 1;
		count <= value;
	end
endmodule
