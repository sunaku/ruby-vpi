=begin
	Copyright 2006 Suraj N. Kurapati

	This file is part of Ruby-VPI.

	Ruby-VPI is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	Ruby-VPI is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
=end

# A specification which verifies the design under test.
require 'hw5_unit_design.rb'
require 'vpi_util'
require 'test/unit'

require 'InputGenerator'
require 'Hw5UnitModel'



class Hw5_unit_spec < Test::Unit::TestCase
	include Vpi

	# Number of input sequences to test.
	NUM_TESTS = 4000

	# Ruby's native int is 31 bits
	RUBY_INTEGER_BITS = 31

	# Used to convert VPI integer into Ruby integer
	VPI_INTEGER_MASK = (2 ** RUBY_INTEGER_BITS.succ) - 1

	# Upper limit of values allowed for an operation's tag.
	OPERATION_TAG_LIMIT = 2 ** 7

	OPERATION_ENCODINGS = {
		:nop => 0,
		:add => 1,
		:sub => 2,
		:mul => 3,
	}

	# Number of cycles needed to reset the DUT
	DUT_RESET_DELAY = 5


	def setup
		@ig = InputGenerator.new(RUBY_INTEGER_BITS)
		@design = Hw5_unit.new

		reset
	end

	def reset
		@design.reset.intVal = 1
		DUT_RESET_DELAY.times {relay_verilog}

		@design.reset.intVal = 0
	end

	def test_pipeline
		operationQueue = []
		numOperations = 0

		begin
			# start a new operation
			if numOperations < NUM_TESTS
				op = Hw5UnitModel::Operation.new(
					Hw5UnitModel::OPERATIONS[rand(Hw5UnitModel::OPERATIONS.size)],
					numOperations % OPERATION_TAG_LIMIT,
					@ig.gen.abs,
					@ig.gen.abs
				)


				@design.a.intVal = op.arg1
				@design.b.intVal = op.arg2
				@design.in_op.intVal = OPERATION_ENCODINGS[op.type]
				@design.in_databits.intVal = op.tag


				operationQueue << op
				numOperations += 1
			end


			# simulate a clock cycle
			relay_verilog


			# verify the output when present
			unless @design.out_databits.hexStrVal =~ /x/
				finishedOp = Hw5UnitModel::Operation.new(
					OPERATION_ENCODINGS.index(@design.out_op.intVal),
					@design.out_databits.intVal
				)
				finishedOp.result = @design.res.intVal & VPI_INTEGER_MASK

				expectedOp = operationQueue.shift


				assert_equal expectedOp.type, finishedOp.type, "incorrect operation"
				assert_equal expectedOp.tag, finishedOp.tag, "incorrect tag"


				# ignore the result of a NOP operation
				unless finishedOp.type == :nop
					assert_equal expectedOp.compute & VPI_INTEGER_MASK, finishedOp.result, "incorrect result"
				end
			end
		end until operationQueue.empty?
	end
end