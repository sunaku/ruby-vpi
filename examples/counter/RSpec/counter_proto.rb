always do
  wait until clock.posedge?

  if reset.high?
    count.intVal = 0
  else
    count.intVal += 1
  end
end
