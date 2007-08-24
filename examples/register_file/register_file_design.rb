# Simulates the design under test for one clock cycle.
def cycle!
  advance_time
end

# Brings the design under test into a blank state.
def reset!
  register.each_memoryWord do |word|
    word.x!
  end
end
