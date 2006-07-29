/**
	An up-counter with synchronous reset.

	@param	Size	The number of bits to use in representing the counter's value.
	@param	clock The clocking signal.
	@param	reset Sets the value of this counter to zero when asserted.
	@param	count The value of this counter.
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
