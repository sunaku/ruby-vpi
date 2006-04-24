=begin
	Copyright 2006 Suraj Kurapati

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

# Note: DUT means "design under test"

require 'vpi_util'
require 'InputGenerator'
require 'Hw5UnitModel'
require 'test/unit'


class TestHw5Unit < Test::Unit::TestCase
	include Vpi

	# Number of input sequences to test.
	NUM_TESTS = 4000

	# Ruby's native int is 31 bits
	RUBY_INTEGER_BITS = 31

	# Used to convert VPI integer into Ruby integer
	VPI_INTEGER_MASK = (2 ** RUBY_INTEGER_BITS.succ) - 1

	# Maximum allowed value of an operation's tag.
	OPERATION_TAG_MAX = (2 ** 7) - 1

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


		# get handles to simulation objects
		@dut_reset = vpi_handle_by_name("hw5_unit_tb.reset", nil)
		@dut_in_tag = vpi_handle_by_name("hw5_unit_tb.in_tag", nil)
		@dut_in_arg1 = vpi_handle_by_name("hw5_unit_tb.in_arg1", nil)
		@dut_in_arg2 = vpi_handle_by_name("hw5_unit_tb.in_arg2", nil)
		@dut_in_type = vpi_handle_by_name("hw5_unit_tb.in_type", nil)

		@dut_out_result = vpi_handle_by_name("hw5_unit_tb.out_result", nil)
		@dut_out_tag = vpi_handle_by_name("hw5_unit_tb.out_tag", nil)
		@dut_out_type = vpi_handle_by_name("hw5_unit_tb.out_type", nil)

		reset
	end

	def reset
		@dut_reset.value = 1
		DUT_RESET_DELAY.times {relay_verilog}

		@dut_reset.value = 0
		relay_verilog

		puts "DUT has been reset"
	end

	def test_pipeline
		operationQueue = []
		numOperations = 0

		begin
			# start a new operation
			if numOperations < NUM_TESTS
				op = Hw5UnitModel::Operation.new(
					Hw5UnitModel::OPERATIONS[rand(Hw5UnitModel::OPERATIONS.size)],

					# NOTE: use +1 because a don't care (x) value becomes a zero when accessed as VpiIntVal
					(numOperations % OPERATION_TAG_MAX) + 1,

					@ig.gen.abs,
					@ig.gen.abs
				)


				@dut_in_arg1.value = op.arg1
				@dut_in_arg2.value = op.arg2
				@dut_in_type.value = OPERATION_ENCODINGS[op.type]
				@dut_in_tag.value = op.tag


				operationQueue << op
				numOperations += 1
			end


			# simulate a clock cycle
			relay_verilog


			# obtain the output
			finishedOp = Hw5UnitModel::Operation.new(
				OPERATION_ENCODINGS.index(@dut_out_type.value),
				@dut_out_tag.value
			)
			finishedOp.result = @dut_out_result.value & VPI_INTEGER_MASK


			# verify the output
			unless finishedOp.tag == 0	# ignore dont-care (X)'s
				expectedOp = operationQueue.shift

				assert_equal expectedOp.type, finishedOp.type, "incorrect operation"
				assert_equal expectedOp.tag, finishedOp.tag, "incorrect tag"

				unless finishedOp.type == :nop
					assert_equal expectedOp.compute & VPI_INTEGER_MASK, finishedOp.result, "incorrect result"
				end
			end
		end until operationQueue.empty?
	end
end


# $ruby_init():
Vpi::relay_verilog


# $ruby_relay():
# do nothing here, because test/unit will automatically run the unit test above
