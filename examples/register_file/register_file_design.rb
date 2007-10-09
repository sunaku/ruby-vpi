# Simulates the design under test for one clock cycle.
def DUT.cycle!
  advance_time
end

# Brings the design under test into a blank state.
def DUT.reset!
  register.each_memoryWord do |word|
    word.x!
  end
end
