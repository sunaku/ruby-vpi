/* This file is the Verilog side of the bench. */
module counter_xunit_bench;

  // instantiate the design under test
    parameter Size = 5;
    reg  clock;
    reg  reset;
    wire [Size - 1 : 0] count;

    counter #(.Size(Size)) counter_xunit_bench_design(.clock(clock), .reset(reset), .count(count));

  // connect to the Ruby side of this bench
    initial begin
      $ruby_init("ruby", "-rubygems", "counter_xunit_bench.rb");
    end

    always begin
      #1 clock = 0;
      #1 $ruby_relay;
      #1 clock = 1;
    end

endmodule
