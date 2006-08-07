/**
	A simple up-counter with synchronous reset.

	@param	Size	Number of bits used to represent the counter's value.
	@param	clock Increments the counter's value upon each positive edge.
	@param	reset Zeroes the counter's value when asserted.
	@param	count The counter's value.
*/
module counter #(parameter Size = 5) (
	input clock,
	input reset,
	output reg [Size - 1 : 0] count
);
	always @(posedge clock) begin
		count <= reset ? 0 : count + 1;
	end
endmodule
