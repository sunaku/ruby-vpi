# This file is a behavioral specification for the design under test.

# lowest upper bound of counter's value
LIMIT = 2 ** Counter.Size.intVal

# maximum allowed value for a counter
MAX = LIMIT - 1

class ResettedCounterValue < Test::Unit::TestCase
  def setup
    Counter.reset!
  end

  def test_zero
    assert_equal 0, Counter.count.intVal
  end

  def test_increment
    LIMIT.times do |i|
      assert_equal i, Counter.count.intVal

      # advance the clock
        relay_verilog
    end
  end
end

class MaximumCounterValue < Test::Unit::TestCase
  def setup
    Counter.reset!

    # increment the counter to maximum value
      MAX.times do relay_verilog end
      assert_equal MAX, Counter.count.intVal
  end

  def test_overflow
    # increment the counter
      relay_verilog

    assert_equal 0, Counter.count.intVal
  end
end
