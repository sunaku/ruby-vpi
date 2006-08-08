# A specification which verifies the design under test.
require 'counter_rspecTest_design.rb'
require 'vpi_util'
require 'rspec'


# replace the design with its prototype
if ENV['PROTO']
	require 'counter_rspecTest_proto.rb'

	module Vpi
		PROTOTYPE = CounterProto.new

		def relay_verilog
			PROTOTYPE.simulate!
		end
	end

	puts 'Replaced design with prototype.'
end


LIMIT = 2 ** Counter::Size # lowest upper bound of counter's value
MAX = LIMIT - 1 # maximum allowed value for a counter


include Vpi

context "A resetted counter's value" do
	setup do
		@design = Counter.new
		@design.reset!
	end

	specify "should be zero" do
		@design.count.intVal.should_be 0
	end

	specify "should increment by one count upon each rising clock edge" do
		LIMIT.times do |i|
			@design.count.intVal.should_be i
			relay_verilog # advance the clock
		end
	end
end

context "A counter with the maximum value" do
	setup do
		@design = Counter.new
		@design.reset!

		# increment the counter to maximum value
		MAX.times do relay_verilog end
		@design.count.intVal.should_be MAX
	end

	specify "should overflow upon increment" do
		relay_verilog # increment the counter
		@design.count.intVal.should_be 0
	end
end