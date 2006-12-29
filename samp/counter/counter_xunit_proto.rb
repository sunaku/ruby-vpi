# This is a prototype of the design under test.

# When prototyping is enabled, simulate invokes this method
# instead of transferring control to the Verilog simulator.
def Counter.simulate!
  if reset.intVal == 1
    count.intVal = 0
  else
    count.intVal += 1
  end
end
