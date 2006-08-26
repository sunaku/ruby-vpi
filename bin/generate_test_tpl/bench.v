<%
  # Returns a comma-separated string of parameter declarations in Verilog module instantiation format.
  def make_inst_param_decl(paramNames)
    paramNames.inject([]) {|acc, param| acc << ".#{param}(#{param})"}.join(', ')
  end

  clockSignal = aModuleInfo.portNames.first
%>
// This is the Verilog side of the bench.
module <%= aOutputInfo.verilogBenchName %>;

  // provide parameters for the design under test
  <% aModuleInfo.paramDecls.each do |decl| %>
    parameter <%= decl %>;
  <% end %>

  // provide accessors for the design under test
  <%
    aModuleInfo.portDecls.each do |decl|
      { 'input' => 'reg', 'output' => 'wire' }.each_pair do |key, val|
        decl.sub! %r{\b#{key}\b(.*?)$}, "#{val}\\1;"
      end
  %>
    <%= decl.strip %>
  <%
    end
  %>

  // instantiate the design under test
    <%= aModuleInfo.name %><%
      instConfigDecl = make_inst_param_decl(aModuleInfo.paramNames)

      unless instConfigDecl.empty?
    %>#(<%= instConfigDecl %>)<%
      end

    %><%= aOutputInfo.verilogBenchName + aOutputInfo.designSuffix %>(<%= make_inst_param_decl(aModuleInfo.portNames) %>);

  // connect to the Ruby side of this bench
    initial begin
      <%= clockSignal %> = 0;
      $ruby_init("ruby", "-w", "<%= aOutputInfo.rubyBenchPath %>"<%=
        %{, "-f", "s"} if aOutputInfo.specFormat == :RSpec
      %>);
    end

    always begin
      #5 <%= clockSignal %> = ~<%= clockSignal %>;
    end

    always @(posedge <%= clockSignal %>) begin
      #1 $ruby_relay();
    end

endmodule
