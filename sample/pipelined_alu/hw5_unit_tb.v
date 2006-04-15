// Suraj Kurapati
// CMPE-126, Homework 5

`define	 WIDTH			32
`define	 DATABITS		7
`define	 OP_NOP			0
`define	 OP_ADD			1
`define	 OP_SUB			2
`define	 OP_MULT		3

module hw5_unit_tb(
	input														clk
	,input													reset

	,output [`WIDTH-1:0]						out_result
	,output [`DATABITS-1:0]					out_tag
	,output [1:0]										out_type
);


	reg															clock_reg;
	reg															reset_reg;

	reg [`DATABITS-1:0]							in_tag_reg;
	reg [`WIDTH-1:0]								in_arg1_reg;
	reg [`WIDTH-1:0]								in_arg2_reg;
	reg [1:0]												in_type_reg;



	initial begin
		// initialize Ruby-VPI
		#0 $ruby_init("-w", "hw5_unit_tb.rb");

		// reset the system
		#1 clock_reg = 0; reset_reg = 0;
	end


	// generate the clock
	always begin
		#5 clock_reg = !clock_reg;
	end


	// transfer control to Ruby code upon each new clock cycle
	always @(posedge clock_reg) begin
		$monitor("%d: in_tag_reg = %d, in_type_reg = %d, in_arg1_reg = %d, in_arg2_reg = %d, out_result = %d, out_tag = %d, out_type = %d", $time, in_tag_reg, in_type_reg, in_arg1_reg, in_arg2_reg, out_result, out_tag, out_type);

		$ruby_relay();

		$monitor("%d: in_tag_reg = %d, in_type_reg = %d, in_arg1_reg = %d, in_arg2_reg = %d, out_result = %d, out_tag = %d, out_type = %d", $time, in_tag_reg, in_type_reg, in_arg1_reg, in_arg2_reg, out_result, out_tag, out_type);
	end


	// instantiate the design under test
	hw5_unit dut(
		.clk										(clock_reg)
		,.reset									(reset_reg)

		,.in_databits						(in_tag_reg)
		,.a											(in_arg1_reg)
		,.b											(in_arg2_reg)
		,.in_op									(in_type_reg)

		,.res										(out_result)
		,.out_databits					(out_tag)
		,.out_op								(out_type)
	);

endmodule