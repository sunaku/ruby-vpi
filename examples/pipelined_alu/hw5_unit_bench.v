`define WIDTH 32
`define DATABITS 7
`define OP_NOP 0
`define OP_ADD 1
`define OP_SUB 2
`define OP_MULT 3

		module hw5_unit_bench;

			// configuration for the design under test


			// accessors for the design under test
			reg clk	;
reg reset		;
reg [`DATABITS-1:0] in_databits	;
reg [`WIDTH-1:0] a	;
reg [`WIDTH-1:0] b	;
reg [1:0] in_op		;
wire  [`WIDTH-1:0] res	;
wire  [`DATABITS-1:0] out_databits	;
wire  [1:0] out_op;


			// instantiate the design under test
			hw5_unit  hw5_unit_bench_design (.clk(clk), .reset(reset), .in_databits(in_databits), .a(a), .b(b), .in_op(in_op), .res(res), .out_databits(out_databits), .out_op(out_op));


			// interface to Ruby-VPI
			initial begin
				clk = 0;
				$ruby_init("ruby", "-w", "-I", "../../lib", "hw5_unit_bench.rb");
			end

			// generate a 50% duty-cycle clock for the design under test
			always begin
				#5 clk = ~clk;
			end

			// transfer control to Ruby-VPI every clock cycle
			always @(posedge clk) begin
				#1 $ruby_relay();
			end

		endmodule
