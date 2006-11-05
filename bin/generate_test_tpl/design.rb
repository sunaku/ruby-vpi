# This is a Ruby interface to the design under test.
<% aParseInfo.constants.each do |var| %>
<%= var.name.to_ruby_const_name %> = <%= var.value.verilog_to_ruby %>
<% end %>

class << <%= aOutputInfo.designClassName %>
  def reset!
<% aModuleInfo.ports.select { |p| p.input? }[1..-1].each do |port| # using [1..] because the first signal is the clock %>
    <%= port.name %>.hexStrVal = 'x'
<% end %>
  end
end
