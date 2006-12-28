<%
  # Returns a comma-separated string of parameter declarations in Verilog module instantiation format.
  def make_inst_param_decl aParams
    aParams.map do |param|
      ".#{param.name}(#{param.name})"
    end.join(', ')
  end

  clockSignal = aModuleInfo.ports.first.name
%>
/* This file is the Verilog side of the bench. */
module <%= aOutputInfo.verilogBenchName %>;

  // instantiate the design under test
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

  // generate clock for the design under test
    initial <%= clockSignal %> = 0;
    always #5 <%= clockSignal %> = !<%= clockSignal %>;

endmodule
