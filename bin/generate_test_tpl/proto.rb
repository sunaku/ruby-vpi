# This is a prototype of the design under test.
class << <%= aOutputInfo.designClassName %>
  # When prototyping is enabled, this method is invoked
  # instead of relay_verilog to simulate the design.
  def simulate!
    # discard old outputs
<% aModuleInfo.ports.reject { |p| p.input? }.each do |port| %>
      <%= port.name %>.hexStrVal = 'x'
<% end %>

    # process new inputs

    # produce new outputs
  end
end
