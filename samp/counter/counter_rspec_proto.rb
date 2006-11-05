# This is a prototype of the design under test.
class << Counter
  # When prototyping is enabled, this method is invoked
  # instead of Vpi::relay_verilog to simulate the design.
  def simulate!
    if reset.intVal == 1
      count.intVal = 0
    else
      count.intVal += 1
    end
  end
end
