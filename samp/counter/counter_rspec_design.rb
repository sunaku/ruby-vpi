# This is a Ruby interface to the design under test.
class << Counter
  def reset!
    reset.intVal = 1
    relay_verilog
    reset.intVal = 0
  end
end
