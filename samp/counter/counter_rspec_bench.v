// This file is the Verilog side of the bench.
module counter_rspec_bench;

  // instantiate the design under test
    parameter Size = 5;
    reg  clock;
    reg  reset;
    wire [Size - 1 : 0] count;

    counter #(.Size(Size)) counter_rspec_bench_design(.clock(clock), .reset(reset), .count(count));

  // generate clock for the design under test
    initial clock = 0;
    always #5 clock = !clock;

endmodule
