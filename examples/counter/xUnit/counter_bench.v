// This file is the Verilog side of the bench.
module counter_xunit_bench;
  parameter Size = 5;
  reg  clock;
  reg  reset;
  wire [Size - 1 : 0] count;

  counter #(.Size(Size)) counter_xunit_bench_design(.clock(clock), .reset(reset), .count(count));
endmodule
