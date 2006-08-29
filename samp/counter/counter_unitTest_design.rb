# An interface to the design under test.
class Counter
  include Vpi

  Size = 5

  attr_reader :clock, :reset, :count

  def initialize
    @clock = vpi_handle_by_name("counter_unitTest_bench.clock", nil)
    @reset = vpi_handle_by_name("counter_unitTest_bench.reset", nil)
    @count = vpi_handle_by_name("counter_unitTest_bench.count", nil)
  end

  def reset!
    @reset.hexStrVal = 'x'

    @reset.intVal = 1
    relay_verilog
    @reset.intVal = 0
  end
end
