# This file is a behavioral specification for the design under test.

# lowest upper bound of counter's value
LIMIT = 2 ** Counter.Size.intVal

# maximum allowed value for a counter
MAX = LIMIT - 1

describe "A resetted counter's value" do
  setup do
    Counter.reset!
  end

  it "should be zero" do
    Counter.count.intVal.should == 0
  end

  it "should increment upon each rising clock edge" do
    LIMIT.times do |i|
      Counter.count.intVal.should == i
      simulate # increment the counter
    end
  end
end

describe "A counter with the maximum value" do
  setup do
    Counter.reset!

    simulate MAX # increment the counter to maximum value
    Counter.count.intVal.should == MAX
  end

  it "should overflow upon increment" do
    simulate # increment the counter
    Counter.count.intVal.should == 0
  end
end
