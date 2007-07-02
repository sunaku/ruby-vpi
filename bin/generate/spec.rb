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
    # assert <%= aOutputInfo.designClassName %>.<%= port.name %> ..., "<%= port.name %> should ..."
  end
<% end %>
end
<% when :tSpec %>
context "A resetted <%= aOutputInfo.designClassName %>" do
  setup do
    <%= aOutputInfo.designClassName %>.reset!
  end

  specify "should ..." do
    # <%= aOutputInfo.designClassName %>.should ...
  end
end
<% when :rSpec %>
describe <%= aOutputInfo.designClassName %>, " when resetted" do
  before do
    <%= aOutputInfo.designClassName %>.reset!
  end

  it "should ..." do
    # <%= aOutputInfo.designClassName %>.should ...
  end
end
<% else %>
<%= aOutputInfo.designClassName %>.reset!
# raise "should ..." unless <%= aOutputInfo.designClassName %> ...
<% end %>
