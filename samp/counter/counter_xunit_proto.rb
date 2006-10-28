# A prototype of the design under test.
class CounterPrototype < Counter
  def simulate!
    if @reset.intVal == 1
      @count.intVal = 0
    else
      @count.intVal += 1
    end
  end
end
