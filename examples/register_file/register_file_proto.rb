always do
  wait until rdReg.change? or wtReg.change? or rw.change? or enable.change?

  if rw.low?
    targetReg        = register.memoryWord_a[rdReg.intVal]
    outBus.intVal    = targetReg.intVal
  elsif enable.high?
    targetReg        = register.memoryWord_a[wtReg.intVal]
    targetReg.intVal = inBus.intVal
  end
end
