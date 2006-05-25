
		# An interface to the design under test.
		class Hw5_unit
			attr_reader :clk, :reset, :in_databits, :a, :b, :in_op, :res, :out_databits, :out_op

			def initialize
				@clk = Vpi::vpi_handle_by_name("hw5_unit_bench.clk", nil)
@reset = Vpi::vpi_handle_by_name("hw5_unit_bench.reset", nil)
@in_databits = Vpi::vpi_handle_by_name("hw5_unit_bench.in_databits", nil)
@a = Vpi::vpi_handle_by_name("hw5_unit_bench.a", nil)
@b = Vpi::vpi_handle_by_name("hw5_unit_bench.b", nil)
@in_op = Vpi::vpi_handle_by_name("hw5_unit_bench.in_op", nil)
@res = Vpi::vpi_handle_by_name("hw5_unit_bench.res", nil)
@out_databits = Vpi::vpi_handle_by_name("hw5_unit_bench.out_databits", nil)
@out_op = Vpi::vpi_handle_by_name("hw5_unit_bench.out_op", nil)

			end
		end
	