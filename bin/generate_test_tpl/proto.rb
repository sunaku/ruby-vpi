# A prototype of the design under test.
class <%= aOutputInfo.protoClassName %> < <%= aOutputInfo.designClassName %>
  def simulate!
    # discard old outputs
<% aModuleInfo.ports.reject { |p| p.input? }.each do |port| %>
      @<%= port.name %>.hexStrVal = 'x'
<% end %>

    # process new inputs

    # produce new outputs
  end
end
