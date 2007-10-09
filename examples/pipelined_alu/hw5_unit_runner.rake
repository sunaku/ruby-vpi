# Path to a Ruby script that will be invoked before the Verilog
# simulation begins.  This script shall then load the appropriate
# tests to exercise the desired designs in the Verilog simulation.
TEST_LOADER = "hw5_unit_loader.rb"

# Array of paths and shell globs (see the Dir.glob method's documentation for
# details) to source files and directories that contain source files.  These
# source files will be loaded by the simulator before the simulation begins.
SIMULATOR_SOURCES = FileList[
  'hw5_unit.v',
]

# Command-line arguments for the simulator.  These arguments can be
# specified as a string or an array of strings, as demonstrated below:
#
#   :cver => "this is a single string argument",
#   :cver => ["these", "are", "separate", "arguments"],
#   :cver => %w[these are also separate arguments],
#
SIMULATOR_ARGUMENTS = {
  # GPL Cver
  :cver => "",

  # Icarus Verilog
  :ivl => "",

  # Cadence NC-Sim
  :ncsim => "",

  # Synopsys VCS
  :vcs => "",

  # Mentor Modelsim
  :vsim => "",

}

# This task is invoked before the simulator runs.  It
# can be used to make preprations, such as converting
# Verilog header files into Ruby, for the simulation.
task :setup do
  # To learn how to write Rake tasks, please see:
  # http://docs.rubyrake.org/read/chapter/4#page16
end

# This command loads the Ruby-VPI runner template,
# which runs the simulator using the above parameters.
require 'ruby-vpi/runner'
