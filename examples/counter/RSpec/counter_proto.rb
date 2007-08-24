always do
  # "sensitivity list" for this "always" block
  wait until clock.posedge?

  if reset.high?
    count.intVal = 0
  else
    count.intVal += 1
  end

  # we have finished doing interesting things in the
  # current time step, so let us proceed to the next one!
  advance_time
end
