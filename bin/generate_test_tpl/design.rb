# An interface to the design under test.
class <%= aOutputInfo.designClassName %>
  include Vpi

<% aModuleInfo.paramDecls.each do |decl| %>
  <%= decl.strip.capitalize %>
<% end %>

  attr_reader <%=
    aModuleInfo.portNames.inject([]) do |acc, port|
      acc << ":#{port}"
    end.join(', ')
  %>

  def initialize
<% aModuleInfo.portNames.each do |port| %>
    @<%= port %> = vpi_handle_by_name("<%= aOutputInfo.verilogBenchName %>.<%= port %>", nil)
<% end %>
  end

  def reset!
<% aModuleInfo.inputPortNames[1..-1].each do |port| %>
    @<%= port %>.hexStrVal = 'x'
<% end %>
  end
end
