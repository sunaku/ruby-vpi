
		# An interface to the design under test.
		class Counter
			attr_reader :clock, :reset, :count

			def initialize
				@clock = Vpi::vpi_handle_by_name("counter_runner.clock", nil)
@reset = Vpi::vpi_handle_by_name("counter_runner.reset", nil)
@count = Vpi::vpi_handle_by_name("counter_runner.count", nil)

			end
		end
	