require 'test/unit'
require 'int_gen'

class Hw5_unit_spec < Test::Unit::TestCase
  # Number of input sequences to test.
  NUM_TESTS = 4000

  # Bitmask capable of capturing ALU result.
  ALU_RESULT_MASK = (2 ** Hw5_unit::WIDTH) - 1

  # Upper limit of values allowed for an operation's tag.
  OPERATION_TAG_LIMIT = 2 ** Hw5_unit::DATABITS

  def setup
    Hw5_unit.reset!
    @intGen = IntegerGenerator.new(Hw5_unit::WIDTH)
  end

  def test_pipeline
    issuedOps = []
    numIssued = numVerified = 0

    until numVerified == NUM_TESTS
      # issue a new operation
      if numIssued < NUM_TESTS
        op = Hw5_unit::Operation.new(
          Hw5_unit::OPERATIONS[rand(Hw5_unit::OPERATIONS.size)],
          numIssued % OPERATION_TAG_LIMIT,
          @intGen.random,
          @intGen.random
        )

        Hw5_unit.a.intVal           = op.arg1
        Hw5_unit.b.intVal           = op.arg2
        Hw5_unit.in_op.intVal       = op.type
        Hw5_unit.in_databits.intVal = op.tag

        issuedOps << op
        numIssued += 1
      end

      Hw5_unit.cycle!

      # verify result of finished operation
      unless Hw5_unit.out_databits.x?
        finishedOp = Hw5_unit::Operation.new(
          Hw5_unit.out_op.intVal,
          Hw5_unit.out_databits.intVal
        )
        finishedOp.result = Hw5_unit.res.intVal & ALU_RESULT_MASK

        expectedOp = issuedOps.shift
        assert_equal expectedOp.type, finishedOp.type, "incorrect operation"
        assert_equal expectedOp.tag, finishedOp.tag, "incorrect tag"

        unless finishedOp.type == Hw5_unit::OP_NOP
          assert_equal expectedOp.compute & ALU_RESULT_MASK, finishedOp.result, "incorrect result"
        end

        numVerified += 1
      end
    end
  end
end
