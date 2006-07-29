RUBY_VPI_PATH = '../..'

SIMULATOR_SOURCES = ['counter_rspecTest_bench.v', 'counter.v']
SIMULATOR_TARGET = 'counter_rspecTest_bench'
SIMULATOR_ARGS = {
	:cver => '',
	:ivl => '',
	:vcs => '',
	:vsim => '',
}

load "#{RUBY_VPI_PATH}/examples/runner_template.rake"
