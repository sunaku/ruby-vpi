## This runner builds and runs the test. ##

# This specifies the path to Ruby-VPI on your system.
RUBY_VPI_PATH = '<%= aOutputInfo.rubyVpiPath %>'

# These are source files that are to be simulated.
SIMULATOR_SOURCES = [
  '<%= aOutputInfo.verilogBenchPath %>',
  '<%= aModuleInfo.name %>.v',
]

# This specifies the "top module" that is to be simulated.
SIMULATOR_TARGET = '<%= aOutputInfo.verilogBenchName %>'

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

load File.join(RUBY_VPI_PATH, <%=
  OutputInfo::RUNNER_TMPL_REL_PATH.split('/').map do |f|
    %{'#{f}'}
  end.join(', ')
%>)
