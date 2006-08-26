RUBY_VPI_PATH = '<%= aOutputInfo.rubyVpiPath %>'

SIMULATOR_SOURCES = [
  '<%= aOutputInfo.verilogBenchPath %>',
  '<%= aModuleInfo.name %>.v',
]

SIMULATOR_TARGET = '<%= aOutputInfo.verilogBenchName %>'

# command-line arguments for the simulator
SIMULATOR_ARGS = {
  :cver => '',
  :ivl => '',
  :vcs => '',
  :vsim => '',
}

load File.join(RUBY_VPI_PATH, <%=
  OutputInfo::RUNNER_TMPL_REL_PATH.split('/').map do |f|
    %{'#{f}'}
  end.join(', ')
%>)
