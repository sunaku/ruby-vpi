# This is a prototype of the design under test.

# When prototyping is enabled, relay_verilog invokes this method
# instead of transferring control to the Verilog simulator.
def <%= aOutputInfo.designClassName %>.simulate!
  # discard old outputs
<% aModuleInfo.ports.reject { |p| p.input? }.each do |port| %>
    <%= port.name %>.hexStrVal = 'x'
<% end %>

  # process new inputs

  # produce new outputs
end
