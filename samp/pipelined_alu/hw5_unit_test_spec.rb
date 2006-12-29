=begin
  Copyright 2006 Suraj N. Kurapati

  This file is part of Ruby-VPI.

  Ruby-VPI is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  Ruby-VPI is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Ruby-VPI; if not, write to the Free Software Foundation,
  Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
=end

# This file is a behavioral specification for the design under test.

require 'int_gen'

class Hw5_unit_test_spec < Test::Unit::TestCase
  # Number of input sequences to test.
  NUM_TESTS = 4000

  # Bitmask capable of capturing ALU result.
  ALU_RESULT_MASK = (2 ** WIDTH) - 1

  # Upper limit of values allowed for an operation's tag.
  OPERATION_TAG_LIMIT = 2 ** DATABITS

  def setup
    Hw5_unit.reset!
    @intGen = IntegerGenerator.new(WIDTH)
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

          Hw5_unit.a.intVal = op.arg1
          Hw5_unit.b.intVal = op.arg2
          Hw5_unit.in_op.intVal = op.type
          Hw5_unit.in_databits.intVal = op.tag

          issuedOps << op
          numIssued += 1
        end

      simulate

      # verify result of finished operation
        unless Hw5_unit.out_databits.x?
          finishedOp = Operation.new(
            Hw5_unit.out_op.intVal,
            Hw5_unit.out_databits.intVal
          )
          finishedOp.result = Hw5_unit.res.intVal & ALU_RESULT_MASK

          expectedOp = issuedOps.shift
          assert_equal expectedOp.type, finishedOp.type, "incorrect operation"
          assert_equal expectedOp.tag, finishedOp.tag, "incorrect tag"

          unless finishedOp.type == OP_NOP
            assert_equal expectedOp.compute & ALU_RESULT_MASK, finishedOp.result, "incorrect result"
          end

          numVerified += 1
        end
    end
  end
end
