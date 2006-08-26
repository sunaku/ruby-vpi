## This is the Ruby side of the bench. ##

require 'rspec'

# initalize the bench
  require 'bench'
  setup_bench 'counter_rspecTest', :CounterProto

# service the $ruby_relay() callback
  # The RSpec library will take control henceforth.