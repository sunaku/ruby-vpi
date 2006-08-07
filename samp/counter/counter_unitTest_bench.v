module counter_unitTest_bench;

	// configuration for the design under test
	parameter Size = 5;


	// accessors for the design under test
	reg clock;
	reg reset;
	wire [Size - 1:0] count;


	// instantiate the design under test
	counter #(.Size(Size)) counter_unitTest_bench_unitTest_design (.clock(clock), .reset(reset), .count(count));


	// interface to Ruby-VPI
	initial begin
		clock = 0;
		$ruby_init("ruby", "-w", "-I", "../../lib", "counter_unitTest_bench.rb");
	end

	// generate a 50% duty-cycle clock for the design under test
	always begin
		#5 clock = ~clock;
	end

	// transfer control to Ruby-VPI every clock cycle
	always @(posedge clock) begin
		#1 $ruby_relay();
	end

endmodule