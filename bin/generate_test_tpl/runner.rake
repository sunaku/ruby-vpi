# This file runs the test.

# These are Verilog source files that need to be loaded
# by the simulator before they can be simulated.
SIMULATOR_SOURCES = [
  '<%= aModuleInfo.name %>.v',
  '<%= aOutputInfo.verilogBenchPath %>',
]

# These are paths to directories which contain the
# sources listed above, the files they `include, or both.
SIMULATOR_INCLUDES = []

# This specifies the "top module" that is to be simulated.
SIMULATOR_TARGET = '<%= aOutputInfo.verilogBenchName %>'

# These are command-line arguments for the simulator.
# They can be specified as a string or an array of strings:
#
#   :cver => "this is one single argument",
#   :cver => ['these', 'are', 'separate', 'arguments'],
#   :cver => %w[these are also separate arguments],
#
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

# This task is invoked _before_ the simulator runs.
# It can be used to make preprations, such as converting
# Verilog header files into Ruby, for the simulation.
task :setup do
  # To learn how to write Rake tasks, please see:
  # http://docs.rubyrake.org/read/chapter/4#page16
end

# This command loads the Ruby-VPI runner template, which
# runs the simulator according to the information above.
require 'ruby-vpi/runner'
