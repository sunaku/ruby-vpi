
		module counter_runner;

			// configuration for the design under test
			parameter Size = 5;


			// accessors for the design under test
			reg clock	;
reg reset	;
wire  [Size - 1:0] count;


			// instantiate the design under test
			counter #(.Size(Size)) counter_runner_design (.clock(clock), .reset(reset), .count(count));


			// interface to Ruby-VPI
			initial begin
				clock = 0;
				$ruby_init("-w", "counter_runner.rb", "-f", "s");
			end

			// generate a 50% duty-cycle clock for the design under test
			always begin
				#5 clock = ~clock;
			end

			// transfer control to Ruby-VPI every clock cycle
			always @(posedge clock) begin
				$ruby_relay();
			end

		endmodule
	