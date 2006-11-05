# This file is the Ruby side of the bench.

require 'ruby-vpi'
require 'test/unit'

RubyVpi.init_bench 'counter_xunit', :Counter

# service the $ruby_relay callback
  # The xUnit library will take control henceforth.
