# This is a Ruby interface to the design under test.

WIDTH = 32
DATABITS = 7
OP_NOP = 0
OP_ADD = 1
OP_SUB = 2
OP_MULT = 3
OPERATIONS = (OP_NOP..OP_MULT).to_a

# Number of cycles needed to reset this design.
RESET_DELAY = 5

class << Hw5_unit
  def reset!
    reset.hexStrVal = 'x'
    in_databits.hexStrVal = 'x'
    a.hexStrVal = 'x'
    b.hexStrVal = 'x'
    in_op.hexStrVal = 'x'


    reset.intVal = 1

    RESET_DELAY.times do
      relay_verilog
    end

    reset.intVal = 0
  end
end


# Represents an ALU operation.
class Operation
  attr_accessor :type, :tag, :arg1, :arg2, :stage, :result

  def initialize(type, tag, arg1 = 0, arg2 = 0)
    raise ArgumentError unless OPERATIONS.include? type

    @type = type
    @tag = tag
    @arg1 = arg1
    @arg2 = arg2

    @stage = 0
  end

  # Computes the result of this operation.
  def compute
    case @type
      when OP_ADD
        @arg1 + @arg2

      when OP_SUB
        @arg1 - @arg2

      when OP_MULT
        @arg1 * @arg2

      when OP_NOP
        nil

      else
        raise
    end
  end

  def compute!
    @result = compute
  end
end
