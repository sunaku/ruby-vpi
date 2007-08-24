# Ruby prototype of the design under test's Verilog implementation.
def feign!
  if clock.posedge?
    if reset.high?
      count.intVal = 0
    else
      count.intVal += 1
    end
  end
end
