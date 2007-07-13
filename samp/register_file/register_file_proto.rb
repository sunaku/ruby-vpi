# Ruby prototype of the design under test's Verilog implementation.
def feign!
  if rw.low?
    reg           = register.memoryWord_a[rdReg.intVal]
    outBus.intVal = reg.intVal

  elsif enable.high?
    reg           = register.memoryWord_a[wtReg.intVal]
    reg.intVal    = inBus.intVal
  end
end
