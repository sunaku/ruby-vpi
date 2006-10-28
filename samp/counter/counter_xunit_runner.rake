## This file builds and runs the test.

# These are source files that are to be compiled.
SIMULATOR_SOURCES = [
  'counter_xunit_bench.v',
]

# These are paths to directories which contain the
# sources listed above, their dependencies, or both.
SIMULATOR_INCLUDES = []

# This specifies the "top module" that is to be simulated.
SIMULATOR_TARGET = 'counter_xunit_bench'

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
