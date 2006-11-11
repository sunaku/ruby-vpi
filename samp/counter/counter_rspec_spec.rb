# This file is a behavioral specification for the design under test.

# lowest upper bound of counter's value
LIMIT = 2 ** Counter.Size.intVal

# maximum allowed value for a counter
MAX = LIMIT - 1

context "A resetted counter's value" do
  setup do
    Counter.reset!
  end

  specify "should be zero" do
    Counter.count.intVal.should_equal 0
  end

  specify "should increment by one count upon each rising clock edge" do
    LIMIT.times do |i|
      Counter.count.intVal.should_equal i
      relay_verilog # increment the counter
    end
  end
end

context "A counter with the maximum value" do
  setup do
    Counter.reset!

    # increment the counter to maximum value
    MAX.times {relay_verilog}
    Counter.count.intVal.should_equal MAX
  end

  specify "should overflow upon increment" do
    relay_verilog # increment the counter
    Counter.count.intVal.should_equal 0
  end
end
