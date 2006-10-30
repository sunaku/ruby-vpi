<%
  # Returns a comma-separated string of parameter declarations in Verilog module instantiation format.
  def make_inst_param_decl aParams
    aParams.map do |param|
      ".#{param.name}(#{param.name})"
    end.join(', ')
  end

  clockSignal = aModuleInfo.ports.first.name
%>
/* This is the Verilog side of the bench. */
module <%= aOutputInfo.verilogBenchName %>;

  // instantiate the design under test
<% aModuleInfo.parameters.each do |param| %>
    <%= param.decl %>;
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

  // connect to the Ruby side of this bench
    initial begin
      <%= clockSignal %> = 0;
      $ruby_init("ruby", "-w", "-rubygems", "<%= aOutputInfo.rubyBenchPath %>"<%=
        %{, "-f", "s"} if aOutputInfo.specFormat == :rSpec
      %>);
    end

    always begin
      #5 <%= clockSignal %> = ~<%= clockSignal %>;
    end

    always @(posedge <%= clockSignal %>) begin
      #1 $ruby_relay;
    end

endmodule
