# This file is the Ruby side of the bench.

require 'ruby-vpi'
require 'ruby-vpi/rspec'

RubyVpi.init_bench 'counter_rspec', :Counter

# service the $ruby_relay callback
  # The rSpec library will take control henceforth.
