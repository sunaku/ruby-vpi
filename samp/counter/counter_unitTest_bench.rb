## This is the Ruby side of the bench. ##

require 'ruby-vpi'
require 'test/unit'

RubyVPI.init_bench 'counter_unitTest', :CounterProto

# service the $ruby_relay() callback
  # The UnitTest library will take control henceforth.