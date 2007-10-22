if RubyVPI::USE_PROTOTYPE
  always do
    wait until DUT.clock.posedge?

    if DUT.reset.t?
      DUT.count.intVal = 0
    else
      DUT.count.intVal += 1
    end
  end
end
