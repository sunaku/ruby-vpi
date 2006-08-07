require 'counter_unitTest_design.rb'

# A prototype of the design under test.
class CounterProto < Counter
	def simulate!
		if @reset.intVal == 1
			@count.intVal = 0
		else
			@count.intVal += 1
		end
	end
end
