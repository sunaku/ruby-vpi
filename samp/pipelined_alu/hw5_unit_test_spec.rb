## This specification verifies the design under test.
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

require 'InputGenerator'

class Hw5_unit_test_spec < Test::Unit::TestCase
  include Vpi

  # Number of input sequences to test.
  NUM_TESTS = 4000

  # Bitmask capable of capturing ALU result.
  ALU_RESULT_MASK = (2 ** Hw5_unit::WIDTH) - 1

  # Upper limit of values allowed for an operation's tag.
  OPERATION_TAG_LIMIT = 2 ** Hw5_unit::DATABITS

  def setup
    @design = Hw5_unit.new
    @design.reset!

    @inputGen = InputGenerator.new(Hw5_unit::WIDTH)
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
            @inputGen.gen,
            @inputGen.gen
          )

          @design.a.intVal = op.arg1
          @design.b.intVal = op.arg2
          @design.in_op.intVal = op.type
          @design.in_databits.intVal = op.tag

          issuedOps << op
          numIssued += 1
        end

      relay_verilog

      # verify result of finished operation
        unless @design.out_databits.x?
          finishedOp = Hw5_unit::Operation.new(
            @design.out_op.intVal,
            @design.out_databits.intVal
          )
          finishedOp.result = @design.res.intVal & ALU_RESULT_MASK

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
