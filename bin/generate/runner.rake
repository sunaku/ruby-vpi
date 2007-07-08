# This file runs the test.

# Array of paths and shell globs (see the Dir.glob method's
# documentation for details) to source files and directories that
# contain source files, which must be loaded by the simulator.
SIMULATOR_SOURCES = FileList[
  '<%= aModuleInfo.name %>.v',
  '<%= aOutputInfo.verilogBenchPath %>',
]

# These are command-line arguments for the simulator.  They can be
# specified as a string or an array of strings, as demonstrated below:
#
#   :cver => "this is a single string argument",
#   :cver => ["these", "are", "separate", "arguments"],
#   :cver => %w[these are also separate arguments],
#
SIMULATOR_ARGUMENTS = {
<% RubyVpi::Config::SIMULATORS.each_pair do |id, sim| %>
  # <%= sim.name %>
  :<%= id %> => "",

<% end %>
}

# This task is invoked BEFORE the simulator runs.  It
# can be used to make preprations, such as converting
# Verilog header files into Ruby, for the simulation.
task :setup do
  # To learn how to write Rake tasks, please see:
  # http://docs.rubyrake.org/read/chapter/4#page16
end

# This command loads the Ruby-VPI runner template, which
# runs the simulator according to the above parameters.
require 'ruby-vpi/runner'