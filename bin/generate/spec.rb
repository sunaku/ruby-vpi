<% dut = aOutputInfo.designClassName %>

<% case aOutputInfo.specFormat %>
<% when :xUnit %>
require 'test/unit'

class <%= aOutputInfo.specClassName %> < Test::Unit::TestCase
  def setup
    <%= dut %>.reset!
  end
<% aModuleInfo.ports.each do |port| %>

  def test_<%= port.name %>
    # assert <%= dut %>.<%= port.name %> ..., "<%= port.name %> should ..."
  end
<% end %>
end
<% when :tSpec %>
require 'test/spec'

context "A resetted <%= dut %>" do
  setup do
    <%= dut %>.reset!
  end

  specify "should ..." do
    # <%= dut %>.should ...
  end
end
<% when :rSpec %>
require 'spec'

describe <%= dut %>, " when resetted" do
  before do
    <%= dut %>.reset!
  end

  it "should ..." do
    # <%= dut %>.should ...
  end
end
<% else %>
<%= dut %>.reset!
# raise "should ..." unless <%= dut %> ...
<% end %>
