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
  <%=
    case aOutputInfo.specFormat
      when :UnitTest, :RSpec
        "# ... #{aOutputInfo.specFormat} will take control from here."

      else
        aOutputInfo.specClassName + '.new'
    end
  %>
