# An interface to the design under test.
class Hw5_unit
  include Vpi

  WIDTH = 32
  DATABITS = 7
  OP_NOP = 0
  OP_ADD = 1
  OP_SUB = 2
  OP_MULT = 3
  
  # Number of cycles needed to reset this design.
  RESET_DELAY = 5

  # Supported types of ALU operations.
  OPERATIONS = [ :add, :sub, :mul, :nop ]

  attr_reader :clk, :reset, :in_databits, :a, :b, :in_op, :res, :out_databits, :out_op

  def initialize
    @clk = vpi_handle_by_name("hw5_unit_test_bench.clk", nil)
    @reset = vpi_handle_by_name("hw5_unit_test_bench.reset", nil)
    @in_databits = vpi_handle_by_name("hw5_unit_test_bench.in_databits", nil)
    @a = vpi_handle_by_name("hw5_unit_test_bench.a", nil)
    @b = vpi_handle_by_name("hw5_unit_test_bench.b", nil)
    @in_op = vpi_handle_by_name("hw5_unit_test_bench.in_op", nil)
    @res = vpi_handle_by_name("hw5_unit_test_bench.res", nil)
    @out_databits = vpi_handle_by_name("hw5_unit_test_bench.out_databits", nil)
    @out_op = vpi_handle_by_name("hw5_unit_test_bench.out_op", nil)
  end

  def reset!
    @reset.hexStrVal = 'x'
    @in_databits.hexStrVal = 'x'
    @a.hexStrVal = 'x'
    @b.hexStrVal = 'x'
    @in_op.hexStrVal = 'x'

    @reset.intVal = 1
    RESET_DELAY.times {relay_verilog}
    @reset.intVal = 0
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
        when :add
          @arg1 + @arg2

        when :sub
          @arg1 - @arg2

        when :mul
          @arg1 * @arg2

        when :nop
          nil

        else
          raise
      end
    end

    def compute!
      @result = compute
    end
  end
end
