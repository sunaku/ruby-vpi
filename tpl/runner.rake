# A template to simplify building and running examples. This file is meant to be embedded in another Rakefile, which bears the responsibility of defining the following variables.
#
# = Required variables
# RUBY_VPI_PATH:: Path to the Ruby-VPI directory.
# SIMULATOR_SOURCES:: Array of paths to source files needed by the simulator.
# SIMULATOR_TARGET:: Name of the Verilog module to be simulated.
# SIMULATOR_ARGS:: A hash containing keys for each simulator task (same as Rakefile task names) and values containing command-line arguments for each simulator.
#
# = Usage
# When using one simulator after another, ensure that Ruby-VPI is properly compiled for the new simulator by invoking the _clobber_ cleaning task.

=begin
	Copyright 2006 Suraj N. Kurapati

	This file is part of Ruby-VPI.

	Ruby-VPI is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	Ruby-VPI is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Ruby-VPI; if not, write to the Free Software Foundation,
	Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
=end

require 'rake/clean'

task :default do
	Rake.application.options.show_task_pattern = //
	Rake.application.display_tasks_and_comments
end


# check for required variables
raise ArgumentError, "Required variables are undefined." unless
	defined?(RUBY_VPI_PATH) &&
	defined?(SIMULATOR_SOURCES) &&
	defined?(SIMULATOR_TARGET) &&
	defined?(SIMULATOR_ARGS)


SIMULATOR_SOURCES_STRING = SIMULATOR_SOURCES.join(' ')
SHARED_OBJ_PATH = "#{RUBY_VPI_PATH}/ruby-vpi.so"
NORMAL_OBJ_PATH = "#{RUBY_VPI_PATH}/ruby-vpi.o"


# propogate cleaning events to Ruby-VPI
task :clobber do |t|
	cd RUBY_VPI_PATH do
		sh "rake clean"
	end
end


# Builds Ruby-VPI using the given argument strings.
def buildRubyVpi aCompilerFlags = nil, aLinkerFlags = nil
	unless File.exist?(NORMAL_OBJ_PATH) and File.exist?(SHARED_OBJ_PATH)
		command = 'rake'
		command << " CFLAGS='#{aCompilerFlags}'" if aCompilerFlags
		command << " LDFLAGS='#{aLinkerFlags}'" if aLinkerFlags

		cd RUBY_VPI_PATH do
			sh command
		end
	end
end


# Silently copies the given source path to the given destination if necessary.
def silentCopy *aArgs
	safe_ln *aArgs rescue true
end


desc "Simulate with Pragmatic C - Cver."
task :cver => 'cver:run'

namespace 'cver' do
	task :run => [:build].concat(SIMULATOR_SOURCES) do |t|
		sh "cver #{SIMULATOR_ARGS[:cver]} +loadvpi=#{SHARED_OBJ_PATH}:vlog_startup_routines_bootstrap #{SIMULATOR_SOURCES_STRING}"
	end

	task :build do
		buildRubyVpi "-DPRAGMATIC_CVER", "-export-dynamic"
	end

	CLOBBER.include 'verilog.log'
end


desc "Simulate with Icarus Verilog."
task :ivl => 'ivl:run'

namespace 'ivl' do
	task :run => [:build].concat(SIMULATOR_SOURCES) do |t|
		sh "iverilog #{SIMULATOR_ARGS[:ivl]} -y. -mruby-vpi #{SIMULATOR_SOURCES_STRING}"
		sh "vvp -M. a.out"
	end

	task :build do
		buildRubyVpi "-DICARUS_VERILOG"
		silentCopy SHARED_OBJ_PATH, 'ruby-vpi.vpi'
	end

	CLEAN.include 'ruby-vpi.vpi', 'a.out'
end


desc "Simulate with Synopsys VCS."
task :vcs => 'vcs:run'

namespace 'vcs' do
	task :run => [:build, "#{RUBY_VPI_PATH}/tpl/synopsys_vcs.tab"].concat(SIMULATOR_SOURCES) do |t|
		require 'rbconfig'

		sh "vcs #{SIMULATOR_ARGS[:vcs]} -R +v2k +vpi -LDFLAGS '#{File.expand_path(NORMAL_OBJ_PATH)} -L#{Config::CONFIG['libdir']} #{Config::CONFIG['LIBRUBYARG']} -lpthread' -P #{t.prerequisites[1]} #{SIMULATOR_SOURCES_STRING}"
	end

	task :build do
		buildRubyVpi "-DSYNOPSYS_VCS"
	end

	CLEAN.include 'csrc', 'simv*'
end


desc "Simulate with Mentor Modelsim."
task :vsim => 'vsim:run'

namespace 'vsim' do
	task :run => [:build].concat(SIMULATOR_SOURCES) do |t|
		sh "vlib work"
		sh "vlog #{SIMULATOR_ARGS[:vsim]} #{SIMULATOR_SOURCES_STRING}"
		sh "vsim -c #{SIMULATOR_TARGET} -pli #{SHARED_OBJ_PATH} -do 'run -all'"
	end

	task :build do
		buildRubyVpi "-DMENTOR_MODELSIM"
	end

	CLEAN.include 'work'
	CLOBBER.include 'transcript'
end
