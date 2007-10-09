# Simulates the design under test for one clock cycle.
def DUT.cycle!
  clock.high!
  advance_time

  clock.low!
  advance_time
end

# Brings the design under test into a blank state.
def DUT.reset!
  reset.high!
  cycle!
  reset.low!
end
