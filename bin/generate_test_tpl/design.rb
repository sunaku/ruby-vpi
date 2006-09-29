# An interface to the design under test.
class <%= aOutputInfo.designClassName %>
  include Vpi

<% (aParseInfo.constants + aModuleInfo.parameters).each do |var| %>
  <%= var.name.to_ruby_const_name %> = <%= var.value %>
<% end %>

  attr_reader <%=
    aModuleInfo.ports.map do |port|
      ":#{port.name}"
    end.join(', ')
  %>

  def initialize
<% aModuleInfo.ports.each do |port| %>
    @<%= port.name %> = vpi_handle_by_name("<%= aOutputInfo.verilogBenchName %>.<%= port.name %>", nil)
<% end %>
  end

  def reset!
<% aModuleInfo.ports.select { |p| p.input? }[1..-1].each do |port| %>
    @<%= port.name %>.hexStrVal = 'x'
<% end %>
  end
end
