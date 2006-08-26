## This is the Ruby side of the bench. ##

require 'test/unit'

# initalize the bench
  require 'bench'
  setup_bench 'counter_unitTest', :CounterProto

# service the $ruby_relay() callback
  # The UnitTest library will take control henceforth.