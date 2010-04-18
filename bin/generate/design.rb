<% clock = aModuleInfo.clock_port.name rescue "YOUR_CLOCK_SIGNAL_HERE" %>
# Simulates the design under test for one clock cycle.
def DUT.cycle!
  <%= clock %>.t!
  advance_time

  <%= clock %>.f!
  advance_time
end

<% reset = aModuleInfo.reset_port.name rescue "YOUR_RESET_SIGNAL_HERE" %>
# Brings the design under test into a blank state.
def DUT.reset!
  <%= reset %>.t!
  cycle!
  <%= reset %>.f!
end
