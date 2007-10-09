if RubyVPI::USE_PROTOTYPE
  always do
    wait until
      DUT.rdReg.change? or
      DUT.wtReg.change? or
      DUT.rw.change? or
      DUT.enable.change?

    if DUT.rw.low?
      target            = DUT.register.memoryWord_a[DUT.rdReg.intVal]
      DUT.outBus.intVal = target.intVal

    elsif DUT.enable.high?
      target            = DUT.register.memoryWord_a[DUT.wtReg.intVal]
      target.intVal     = DUT.inBus.intVal
    end
  end
end
