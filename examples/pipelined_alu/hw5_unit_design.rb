# Simulates the design under test for one clock cycle.
def DUT.cycle!
  clk.t!
  advance_time

  clk.f!
  advance_time
end

# Brings the design under test into a blank state.
def DUT.reset!
  reset.t!
  5.times { cycle! }
  reset.f!
end

OPERATIONS = (DUT.OP_NOP.intVal .. DUT.OP_MULT.intVal).to_a

# Represents an ALU operation.
class Operation
  attr_accessor :type, :tag, :arg1, :arg2, :result

  def initialize(type, tag, arg1 = 0, arg2 = 0)
    raise ArgumentError unless OPERATIONS.include? type

    @type = type
    @tag  = tag
    @arg1 = arg1
    @arg2 = arg2
  end

  # Computes the result of this operation.
  def compute
    case @type
      when DUT.OP_ADD.intVal
        @arg1 + @arg2

      when DUT.OP_SUB.intVal
        @arg1 - @arg2

      when DUT.OP_MULT.intVal
        @arg1 * @arg2
    end
  end
end
