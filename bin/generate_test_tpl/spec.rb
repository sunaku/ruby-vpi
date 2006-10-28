## This specification verifies the design under test.

<%
  case aOutputInfo.specFormat
    when :xUnit
%>
class <%= aOutputInfo.specClassName %> < Test::Unit::TestCase
  include Vpi

  def setup
    @design = <%= aOutputInfo.designClassName %>.new
  end
<% aModuleInfo.ports.each do |port| %>

  def test_<%= port.name %>
  end
<% end %>
end
<%
   when :rSpec
%>
include Vpi

context "A new <%= aOutputInfo.designClassName %>" do
  setup do
    @design = <%= aOutputInfo.designClassName %>.new
    @design.reset!
  end

  specify "should ..." do
    # @design.should ...
  end
end
<%
  else
%>
class <%= aOutputInfo.specClassName %>
  include Vpi

  def initialize
    @design = <%= aOutputInfo.designClassName %>.new
  end
end
<%
  end
%>
