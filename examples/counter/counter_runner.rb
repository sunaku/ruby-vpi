
		require 'counter_spec.rb'

		# service the $ruby_init() callback
		Vpi::relay_verilog

		# service the $ruby_relay() callback
		# RSpec will take control from here.
	