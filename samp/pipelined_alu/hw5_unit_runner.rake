RUBY_VPI_PATH = '../..'

SIMULATOR_SOURCES = ['hw5_unit_bench.v', 'hw5_unit.v']
SIMULATOR_TARGET = 'hw5_unit_bench'
SIMULATOR_ARGS = {
  :cver => '',
  :ivl => '',
  :vcs => '',
  :vsim => '',
}

load "#{RUBY_VPI_PATH}/tpl/runner.rake"