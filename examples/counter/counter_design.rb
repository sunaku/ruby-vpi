
		# An interface to the design under test.
		class Counter
			attr_reader :clock, :reset, :count

			def initialize
				@clock = Vpi::vpi_handle_by_name("counter_bench.clock", nil)
@reset = Vpi::vpi_handle_by_name("counter_bench.reset", nil)
@count = Vpi::vpi_handle_by_name("counter_bench.count", nil)

			end
		end
	