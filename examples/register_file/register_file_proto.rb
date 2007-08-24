# Ruby prototype of the design under test's Verilog implementation.
def feign!
  if rw.low?
    targetReg        = register.memoryWord_a[rdReg.intVal]
    outBus.intVal    = targetReg.intVal
  elsif enable.high?
    targetReg        = register.memoryWord_a[wtReg.intVal]
    targetReg.intVal = inBus.intVal
  end
end
