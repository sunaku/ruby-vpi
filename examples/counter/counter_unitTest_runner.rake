RUBY_VPI_PATH = '../..'

SIMULATOR_SOURCES = ['counter_unitTest_bench.v', 'counter.v']
SIMULATOR_TARGET = 'counter_unitTest_bench'
SIMULATOR_ARGS = {
	:cver => '',
	:ivl => '',
	:vcs => '',
	:vsim => '',
}

load "#{RUBY_VPI_PATH}/tpl/runner.rake"
