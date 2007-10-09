require 'test/unit'
require 'int_gen'

class A_hw5_unit_when_reset < Test::Unit::TestCase
  # Number of input sequences to test.
  NUM_TESTS = 4000

  # Bitmask capable of capturing ALU result.
  ALU_RESULT_MASK = (2 ** DUT.WIDTH.intVal) - 1

  # Upper limit of values allowed for an operation's tag.
  OPERATION_TAG_LIMIT = 2 ** DUT.DATABITS.intVal

  def setup
    DUT.reset!
    @intGen = IntegerGenerator.new(DUT.WIDTH.intVal)
  end

  def test_pipeline
    issuedOps = []
    numIssued = numVerified = 0

    until numVerified == NUM_TESTS
      # issue a new operation
      if numIssued < NUM_TESTS
        op = Operation.new(
          OPERATIONS[rand(OPERATIONS.size)],
          numIssued % OPERATION_TAG_LIMIT,
          @intGen.random,
          @intGen.random
        )

        DUT.a.intVal           = op.arg1
        DUT.b.intVal           = op.arg2
        DUT.in_op.intVal       = op.type
        DUT.in_databits.intVal = op.tag

        issuedOps << op
        numIssued += 1
      end

      DUT.cycle!

      # verify result of finished operation
      unless DUT.out_databits.x?
        finishedOp = Operation.new(
          DUT.out_op.intVal,
          DUT.out_databits.intVal
        )
        finishedOp.result = DUT.res.intVal & ALU_RESULT_MASK

        expectedOp = issuedOps.shift
        assert_equal expectedOp.type, finishedOp.type, "incorrect operation"
        assert_equal expectedOp.tag, finishedOp.tag, "incorrect tag"

        unless finishedOp.type == DUT.OP_NOP.intVal
          assert_equal expectedOp.compute & ALU_RESULT_MASK, finishedOp.result, "incorrect result"
        end

        numVerified += 1
      end
    end
  end
end
