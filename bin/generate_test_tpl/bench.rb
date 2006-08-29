## This is the Ruby side of the bench. ##

require 'ruby-vpi'
<%
  case aOutputInfo.specFormat
    when :UnitTest
%>
require 'test/unit'
<%
    when :RSpec
%>
require 'ruby-vpi/rspec'
<%
  end
%>

RubyVPI.init_bench '<%= aModuleInfo.name + aOutputInfo.suffix %>', :<%= aOutputInfo.protoClassName %>

# service the $ruby_relay callback
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
