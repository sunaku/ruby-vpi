## This runner builds and runs the test. ##

# These are source files that are to be simulated.
SIMULATOR_SOURCES = [
  'counter_unitTest_bench.v',
  'counter.v',
]

# This specifies the "top module" that is to be simulated.
SIMULATOR_TARGET = 'counter_unitTest_bench'

# These are command-line arguments for the simulator.
SIMULATOR_ARGS = {
  # arguments for GPL Cver
  :cver => '',

  # arguments for Icarus Verilog
  :ivl => '',

  # arguments for Synopsys VCS
  :vcs => '',

  # arguments for Mentor Modelsim
  :vsim => '',
}

require 'ruby-vpi/runner'
