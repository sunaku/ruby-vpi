# An interface to the design under test.
class Counter
	Size = 5

	attr_reader :clock, :reset, :count

	def initialize
		@clock = Vpi::vpi_handle_by_name("counter_bench.clock", nil)
		@reset = Vpi::vpi_handle_by_name("counter_bench.reset", nil)
		@count = Vpi::vpi_handle_by_name("counter_bench.count", nil)


		# unset all inputs
		@reset.hexStrVal = 'x'
	end

	def reset!
		@reset.intVal = 1
		Vpi::relay_verilog
		@reset.intVal = 0
	end
end
