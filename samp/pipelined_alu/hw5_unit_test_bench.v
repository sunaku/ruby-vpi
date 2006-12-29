// This file is the Verilog side of the bench.
module hw5_unit_test_bench;
  reg  clk;
  reg  reset;
  reg [`DATABITS-1:0] in_databits;
  reg [`WIDTH-1:0] a;
  reg [`WIDTH-1:0] b;
  reg [1:0] in_op;
  wire [`WIDTH-1:0] res;
  wire [`DATABITS-1:0] out_databits;
  wire [1:0] out_op;

  hw5_unit  hw5_unit_test_bench_design(.clk(clk), .reset(reset), .in_databits(in_databits), .a(a), .b(b), .in_op(in_op), .res(res), .out_databits(out_databits), .out_op(out_op));
endmodule
