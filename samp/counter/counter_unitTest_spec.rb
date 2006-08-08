# A specification which verifies the design under test.
require 'counter_unitTest_design.rb'
require 'vpi_util'
require 'test/unit'


# replace the design with its prototype
if ENV['PROTO']
	require 'counter_unitTest_proto.rb'

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


class ResettedCounterValue < Test::Unit::TestCase
	include Vpi

	def setup
		@design = Counter.new
		@design.reset!
	end

	def test_zero
		assert_equal 0, @design.count.intVal
	end

	def test_increment
		LIMIT.times do |i|
			assert_equal i, @design.count.intVal
			relay_verilog # advance the clock
		end
	end
end

class MaximumCounterValue < Test::Unit::TestCase
	include Vpi

	def setup
		@design = Counter.new
		@design.reset!

		# increment the counter to maximum value
		MAX.times do relay_verilog end
		assert_equal MAX, @design.count.intVal
	end

	def test_overflow
		relay_verilog # increment the counter
		assert_equal 0, @design.count.intVal
	end
end