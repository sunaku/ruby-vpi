<%
  # Returns a comma-separated string of parameter declarations in Verilog module instantiation format.
  def make_inst_param_decl aParams
    aParams.map do |param|
      ".#{param.name}(#{param.name})"
    end.join(', ')
  end
%>
// This file is the Verilog side of the bench.
module <%= aOutputInfo.verilogBenchName %>;
<% aModuleInfo.parameters.each do |param| %>
  parameter <%= param.decl %>;
<% end %>
<% aModuleInfo.ports.each do |port| %>
  <%= port.input? ? 'reg' : 'wire' %> <%= port.size %> <%= port.name %>;
<% end %>

  <%= aModuleInfo.name %> <%
    instConfigDecl = make_inst_param_decl(aModuleInfo.parameters)

    unless instConfigDecl.empty?
    %>#(<%= instConfigDecl %>)<%
    end

  %> <%= aOutputInfo.verilogBenchName %>_design(<%= make_inst_param_decl(aModuleInfo.ports) %>);
endmodule
