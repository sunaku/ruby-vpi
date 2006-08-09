require 'vpi_util'
require 'rspec'

# load the design under test
require 'counter_rspecTest_design.rb'

if ENV['PROTO']
	require 'counter_rspecTest_proto.rb'

	module Vpi
		PROTOTYPE = CounterProto.new

		def relay_verilog
			PROTOTYPE.simulate!
		end

		puts "#{__FILE__}: verifying prototype instead of design"
	end
end

# load the specification
require 'counter_rspecTest_spec.rb'

# service the $ruby_init() callback
Vpi::relay_verilog

# service the $ruby_relay() callback
# RSpec will take control from here.