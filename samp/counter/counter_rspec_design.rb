# This is a Ruby interface to the design under test.

# This method resets the design under test.
def Counter.reset!
  reset.intVal = 1
  relay_verilog
  reset.intVal = 0
end
