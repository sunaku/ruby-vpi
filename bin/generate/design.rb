<% clock = aModuleInfo.clock_port.name rescue "YOUR_CLOCK_SIGNAL_HERE" %>
# Simulates the design under test for one clock cycle.
def cycle!
  <%= clock %>.high!
  advance_time
  <%= clock %>.low!
  advance_time
end

<% reset = aModuleInfo.reset_port.name rescue "YOUR_RESET_SIGNAL_HERE" %>
# Brings the design under test into a blank state.
def reset!
  <%= reset %>.high!
  cycle!
  <%= reset %>.low!
end
