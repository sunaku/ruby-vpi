# This file runs the test.

# These are source files that are to be compiled.
SIMULATOR_SOURCES = [
  'hw5_unit.v',
  'hw5_unit_test_bench.v',
]

# These are paths to directories which contain the
# sources listed above, their dependencies, or both.
SIMULATOR_INCLUDES = []

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
