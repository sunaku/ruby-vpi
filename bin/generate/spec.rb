<% case aOutputInfo.specFormat %>
<% when :xUnit %>
require 'test/unit'

class A_<%= aModuleInfo.name %>_when_reset < Test::Unit::TestCase
  def setup
    DUT.reset!
  end
<% aModuleInfo.ports.each do |port| %>

  def test_<%= port.name %>
    # assert DUT.<%= port.name %> ..., "<%= port.name %> should ..."
  end
<% end %>
end
<% when :tSpec %>
require 'test/spec'

context "A #{DUT.name}, when reset" do
  setup do
    DUT.reset!
  end

  specify "should ..." do
    # DUT.should ...
  end
end
<% when :rSpec %>
require 'spec'

describe "A #{DUT.name}, when reset" do
  before do
    DUT.reset!
  end

  it "should ..." do
    # DUT.should ...
  end
end
<% else %>
DUT.reset!
# raise "should ..." unless DUT ...
<% end %>
