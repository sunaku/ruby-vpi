# This is a prototype of the design under test.

# When prototyping is enabled, Vpi::advance_time invokes this
# method instead of transferring control to the Verilog simulator.
def Counter.simulate!
  if clock.intVal == 1
    if reset.intVal == 1
      count.intVal = 0
    else
      count.intVal += 1
    end
  end
end
