# This file is a behavioral specification for the design under test.

<%
  case aOutputInfo.specFormat
    when :xUnit
%>
class <%= aOutputInfo.specClassName %> < Test::Unit::TestCase
  def setup
    <%= aOutputInfo.designClassName %>.reset!
  end
<% aModuleInfo.ports.each do |port| %>

  def test_<%= port.name %>
  end
<% end %>
end
<%
   when :rSpec, :tSpec
%>
context "A new <%= aOutputInfo.designClassName %>" do
  setup do
    <%= aOutputInfo.designClassName %>.reset!
  end

  specify "should ..." do
    # <%= aOutputInfo.designClassName %>.should ...
  end
end
<%
  else
%>
class <%= aOutputInfo.specClassName %>
  def initialize
    <%= aOutputInfo.designClassName %>.reset!
  end
end
<%
  end
%>
