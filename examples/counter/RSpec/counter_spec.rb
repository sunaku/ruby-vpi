require 'spec'

# lowest upper bound of counter's value
LIMIT = 2 ** DUT.Size.intVal

# maximum allowed value for a counter
MAX = LIMIT - 1

describe "A #{DUT.name} after being reset" do
  before(:each) do
    DUT.reset! # reset the counter
  end

  it "should be zero" do
    DUT.count.intVal.should == 0
  end

  it "should increment upon each subsequent posedge" do
    LIMIT.times do |i|
      DUT.count.intVal.should == i
      DUT.cycle! # increment the counter
    end
  end
end

describe "A #{DUT.name} with the maximum value" do
  before(:each) do
    DUT.reset! # reset the counter

    # increment the counter to maximum value
    MAX.times { DUT.cycle! }
    DUT.count.intVal.should == MAX
  end

  it "should overflow upon increment" do
    DUT.cycle! # increment the counter
    DUT.count.intVal.should == 0
  end
end
