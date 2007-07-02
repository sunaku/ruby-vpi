# This is a Ruby interface to the design under test.
<% aParseInfo.constants.each do |var| %>
<%= var.name.to_ruby_const_name %> = <%= var.value.verilog_to_ruby %>
<% end %>

# This method resets the design under test.
def <%= aOutputInfo.designClassName %>.reset!
<% aModuleInfo.ports.select {|p| p.input?}.each do |port| %>
  <%= port.name %>.hexStrVal = 'x'
<% end %>
end
