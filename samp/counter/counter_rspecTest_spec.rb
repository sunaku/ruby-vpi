## This specification verifies the design under test. ##

# lowest upper bound of counter's value
LIMIT = 2 ** Counter::Size

# maximum allowed value for a counter
MAX = LIMIT - 1

include Vpi

context "A resetted counter's value" do
  setup do
    @design = Counter.new
    @design.reset!
  end

  specify "should be zero" do
    @design.count.intVal.should_be 0
  end

  specify "should increment by one count upon each rising clock edge" do
    LIMIT.times do |i|
      @design.count.intVal.should_be i

      # advance the clock
        relay_verilog
    end
  end
end

context "A counter with the maximum value" do
  setup do
    @design = Counter.new
    @design.reset!

    # increment the counter to maximum value
      MAX.times do relay_verilog end
      @design.count.intVal.should_be MAX
  end

  specify "should overflow upon increment" do
    # increment the counter
      relay_verilog

    @design.count.intVal.should_be 0
  end
end