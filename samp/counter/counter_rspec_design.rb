# This is a Ruby interface to the design under test.

# This method resets the design under test.
def Counter.reset!
  # assert the reset signal for two clock cycles
  reset.intVal = 1
  2.times {relay_verilog}
  reset.intVal = 0
end
