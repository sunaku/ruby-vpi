/* This is the Verilog side of the bench. */

`define WIDTH 32
`define DATABITS 7
`define OP_NOP	0
`define OP_ADD 1
`define OP_SUB	2
`define OP_MULT 3

module hw5_unit_test_bench;

  // instantiate the design under test

    reg  clk;
    reg  reset;
    reg [`DATABITS-1:0] in_databits;
    reg [`WIDTH-1:0] a;
    reg [`WIDTH-1:0] b;
    reg [1:0] in_op;
    wire [`WIDTH-1:0] res;
    wire [`DATABITS-1:0] out_databits;
    wire [1:0] out_op;

    hw5_unit hw5_unit_test_bench_design(.clk(clk), .reset(reset), .in_databits(in_databits), .a(a), .b(b), .in_op(in_op), .res(res), .out_databits(out_databits), .out_op(out_op));

  // connect to the Ruby side of this bench
    initial begin
      clk = 0;
      $ruby_init("ruby", "-w", "-rubygems", "hw5_unit_test_bench.rb");
    end

    always begin
      #5 clk = ~clk;
    end

    always @(posedge clk) begin
      #1 $ruby_relay;
    end

endmodule
