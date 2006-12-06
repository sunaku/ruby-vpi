# This file runs the test.

# These are source files that are to be compiled.
SIMULATOR_SOURCES = [
  '<%= aModuleInfo.name %>.v',
  '<%= aOutputInfo.verilogBenchPath %>',
]

# These are paths to directories which contain the
# sources listed above, their dependencies, or both.
SIMULATOR_INCLUDES = []

# This specifies the "top module" that is to be simulated.
SIMULATOR_TARGET = '<%= aOutputInfo.verilogBenchName %>'

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

# This task is invoked _before_ the simulator runs.
# See http://docs.rubyrake.org/read/chapter/4#page16
task :setup do
  # actions
end

require 'ruby-vpi/runner'
