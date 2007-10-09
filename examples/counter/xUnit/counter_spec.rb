require 'test/unit'

# lowest upper bound of counter's value
LIMIT = 2 ** DUT.Size.intVal

# maximum allowed value for a counter
MAX = LIMIT - 1

class A_counter_after_being_reset < Test::Unit::TestCase
  def setup
    DUT.reset! # reset the counter
  end

  def test_should_be_zero
    assert_equal( 0, DUT.count.intVal )
  end

  def test_should_increment_upon_each_subsequent_posedge
    LIMIT.times do |i|
      assert_equal( i, DUT.count.intVal )
      DUT.cycle! # increment the counter
    end
  end
end

class A_counter_with_the_maximum_value < Test::Unit::TestCase
  def setup
    DUT.reset! # reset the counter

    # increment the counter to maximum value
    MAX.times { DUT.cycle! }
    assert_equal( MAX, DUT.count.intVal )
  end

  def test_should_overflow_upon_increment
    DUT.cycle! # increment the counter
    assert_equal( 0, DUT.count.intVal )
  end
end
