## This file builds and runs the test.

# These are source files that are to be simulated.
SIMULATOR_SOURCES = [
  'hw5_unit_test_bench.v',
  'hw5_unit.v',
]

# This specifies the "top module" that is to be simulated.
SIMULATOR_TARGET = 'hw5_unit_test_bench'

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