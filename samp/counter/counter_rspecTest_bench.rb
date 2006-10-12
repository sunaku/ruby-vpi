## This is the Ruby side of the bench.

require 'ruby-vpi'
require 'ruby-vpi/rspec'

RubyVpi.init_bench 'counter_rspecTest', :CounterProto

# service the $ruby_relay callback
  # The RSpec library will take control henceforth.
