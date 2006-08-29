## This file builds and runs the test.

# These are source files that are to be simulated.
SIMULATOR_SOURCES = [
  'counter_unitTest_bench.v',
  'counter.v',
]

# This specifies the "top module" that is to be simulated.
SIMULATOR_TARGET = 'counter_unitTest_bench'

# These are command-line arguments for the simulator.
# They can be specified as a string or an array of strings.
SIMULATOR_ARGS = {
  # GPL Cver
  :cver => '',

  # Icarus Verilog
  :ivl => '',

  # Synopsys VCS
  :vcs => '',

  # Mentor Modelsim
  :vsim => '',
}

require 'ruby-vpi/runner'
