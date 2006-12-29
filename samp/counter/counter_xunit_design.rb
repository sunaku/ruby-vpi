# This is a Ruby interface to the design under test.

# This method resets the design under test.
def Counter.reset!
  reset.intVal = 1
  simulate
  reset.intVal = 0
end
