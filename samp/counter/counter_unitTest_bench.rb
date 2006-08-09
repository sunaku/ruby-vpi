require 'test/unit'

# initalize the bench
require 'bench'
setup_bench 'counter_unitTest', :CounterProto

# service the $ruby_relay() callback
# ... UnitTest will take control from here.