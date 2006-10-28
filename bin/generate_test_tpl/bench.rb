## This is the Ruby side of the bench.

require 'ruby-vpi'
<%
  case aOutputInfo.specFormat
    when :xUnit
%>
require 'test/unit'
<%
    when :rSpec
%>
require 'ruby-vpi/rspec'
<%
  end
%>

RubyVpi.init_bench '<%= aModuleInfo.name + aOutputInfo.suffix %>', :<%= aOutputInfo.protoClassName %>

# service the $ruby_relay callback
<%
  case aOutputInfo.specFormat
    when :xUnit, :rSpec
%>
  # The <%= aOutputInfo.specFormat %> library will take control henceforth.
<%
  else
%>
  <%= aOutputInfo.specClassName + '.new' %>
<%
  end
%>
