## This specification verifies the design under test. ##

# lowest upper bound of counter's value
LIMIT = 2 ** Counter::Size

# maximum allowed value for a counter
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

      # advance the clock
        relay_verilog
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
    # increment the counter
      relay_verilog

    assert_equal 0, @design.count.intVal
  end
end