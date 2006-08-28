SIMULATOR_SOURCES = ['hw5_unit_bench.v', 'hw5_unit.v']
SIMULATOR_TARGET = 'hw5_unit_bench'
SIMULATOR_ARGS = {
  :cver => '',
  :ivl => '',
  :vcs => '',
  :vsim => '',
}

# build and run the test
  require 'rubygems'
  require 'ruby-vpi'

  RubyVPI.load_test_runner