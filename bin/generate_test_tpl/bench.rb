# This file is the Ruby side of the bench.

require 'ruby-vpi'
RubyVpi.init_bench :<%= aOutputInfo.designClassName %>, :<%= aOutputInfo.specFormat %>
<% if aOutputInfo.specFormat == :generic %>

<%= aOutputInfo.specClassName + '.new' %>
<% end %>
