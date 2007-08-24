require 'test/unit'

# lowest upper bound of counter's value
LIMIT = 2 ** Counter::Size

# maximum allowed value for a counter
MAX = LIMIT - 1

class ResettedCounterValue < Test::Unit::TestCase
  def setup
    Counter.reset!
  end

  def test_zero
    assert_equal( 0, Counter.count.intVal )
  end

  def test_increment
    LIMIT.times do |i|
      assert_equal( i, Counter.count.intVal )
      Counter.cycle! # increment the counter
    end
  end
end

class MaximumCounterValue < Test::Unit::TestCase
  def setup
    Counter.reset!

    # increment the counter to maximum value
    MAX.times { Counter.cycle! }
    assert_equal( MAX, Counter.count.intVal )
  end

  def test_overflow
    Counter.cycle! # increment the counter
    assert_equal( 0, Counter.count.intVal )
  end
end
