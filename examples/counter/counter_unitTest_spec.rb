# A specification which verifies the design under test.
require 'counter_unitTest_design.rb'
require 'vpi_util'
require 'test/unit'


# Lowest upper bound of counter's value
LIMIT = 2 ** Counter::Size

# Maximum allowed value for a counter
MAX = LIMIT - 1


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

		# increment to maximum value
		MAX.times do relay_verilog end
		assert_equal MAX, @design.count.intVal
	end

	def test_overflow
		relay_verilog # increment the counter
		assert_equal 0, @design.count.intVal
	end
end