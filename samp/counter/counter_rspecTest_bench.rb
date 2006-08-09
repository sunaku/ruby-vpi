require 'rspec'

# initalize the bench
require 'bench'
setup_bench 'counter_rspecTest', :CounterProto

# service the $ruby_relay() callback
# ... RSpec will take control from here.