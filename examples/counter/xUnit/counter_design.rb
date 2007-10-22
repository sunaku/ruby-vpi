
# Simulates the design under test for one clock cycle.
def DUT.cycle!
  clock.t!
  advance_time

  clock.f!
  advance_time
end

# Brings the design under test into a blank state.
def DUT.reset!
  reset.t!
  cycle!
  reset.f!
end
