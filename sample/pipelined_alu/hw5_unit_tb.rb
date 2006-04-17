# Suraj Kurapati
# CMPE-126, Homework 5
# Ruby-VPI test bench for hw5_unit module.

require 'InputGenerator'
require 'Hw5UnitModel'
require 'test/unit'
# require 'pp'


class TestHw5Unit
	include Test::Unit::Assertions

	NUM_VECTORS = 4000

	VPI_INTEGER_MASK = (2 ** 32) - 1

	OPERATION_TAG_MAX = (2 ** 7) - 1

	OPERATION_ENCODINGS = {
		:nop => 0,
		:add => 1,
		:sub => 2,
		:mul => 3,
	}


	def initialize
		@ig32 = InputGenerator.new(31)	# ruby's native int is 31 bits


		# get handles to simulation objects
		@dut_in_tag = VPI::handle_by_name("hw5_unit_tb.in_tag_reg")
		@dut_in_arg1 = VPI::handle_by_name("hw5_unit_tb.in_arg1_reg")
		@dut_in_arg2 = VPI::handle_by_name("hw5_unit_tb.in_arg2_reg")
		@dut_in_type = VPI::handle_by_name("hw5_unit_tb.in_type_reg")

		@dut_out_result = VPI::handle_by_name("hw5_unit_tb.out_result")
		@dut_out_tag = VPI::handle_by_name("hw5_unit_tb.out_tag")
		@dut_out_type = VPI::handle_by_name("hw5_unit_tb.out_type")
	end


	def run
		operationQueue = []
		numOperations = 0

		begin
			# start a new operation
			if numOperations < NUM_VECTORS
				op = Hw5UnitModel::Operation.new(
					Hw5UnitModel::OPERATIONS[rand(Hw5UnitModel::OPERATIONS.size)],

					# NOTE: use +1 because a don't care (x) value becomes a zero when accessed with VPI::Handle.value
					(numOperations % OPERATION_TAG_MAX) + 1,

					@ig32.gen.abs,
					@ig32.gen.abs
				)


				@dut_in_arg1.value = op.arg1
				@dut_in_arg2.value = op.arg2
				@dut_in_type.value = OPERATION_ENCODINGS[op.type]
				@dut_in_tag.value = op.tag


				operationQueue << op
				numOperations += 1
			end


			# simulate a clock cycle
			VPI::relay_verilog


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
VPI::relay_verilog


# $ruby_relay():
TestHw5Unit.new.run

puts "#{__FILE__} passed successfully!"
