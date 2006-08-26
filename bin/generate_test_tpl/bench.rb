# This is the Ruby side of the bench.
<%
  case aOutputInfo.specFormat
    when :UnitTest
%>
require 'test/unit'
<%
    when :RSpec
%>
require 'rspec'
<%
  end
%>

# initalize the bench
  require 'bench'
  setup_bench '<%= aModuleInfo.name + aOutputInfo.suffix %>', :<%= aOutputInfo.protoClassName %>

# service the $ruby_relay() callback
<%
  case aOutputInfo.specFormat
    when :UnitTest, :RSpec
%>
  # The <%= aOutputInfo.specFormat %> library will take control henceforth.
<%
  else
%>
  <%= aOutputInfo.specClassName + '.new' %>
<%
  end
%>
