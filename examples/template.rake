# A template to simplify building examples. This file is meant to be embedded in another Rakefile, which bears the responsibility of defining the following variables.
#
# = Required variables
# RUBY_VPI_PATH:: Path to the Ruby-VPI directory.
# SIMULATOR_SOURCES:: Array of paths to source files needed by the simulator.
# SIMULATOR_TARGET:: Name of the Verilog module to be simulated.
# SIMULATOR_ARGS:: A hash containing keys for each simulator task (same as Rakefile task names) and values containing command-line arguments for each simulator.
#
# = Usage
# When using one simulator after another, ensure that Ruby-VPI is properly compiled for the new simulator by invoking a cleaning task, such as _clean_ or _clobber_.

=begin
	Copyright 2006 Suraj N. Kurapati

	This file is part of Ruby-VPI.

	Ruby-VPI is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

	Ruby-VPI is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
=end

require 'rake/clean'


# check for required variables
raise ArgumentError, "Required variables are undefined." unless
	defined?(RUBY_VPI_PATH) &&
	defined?(SIMULATOR_SOURCES) &&
	defined?(SIMULATOR_TARGET) &&
	defined?(SIMULATOR_ARGS)


SIMULATOR_SOURCES_STRING = SIMULATOR_SOURCES.join(' ')
SHARED_OBJ_PATH = "#{RUBY_VPI_PATH}/ruby-vpi.so"
NORMAL_OBJ_PATH = "#{RUBY_VPI_PATH}/ruby-vpi.o"


# determine Ruby libraries available from Ruby-VPI
RUBY_LIBS = {}

FileList["#{RUBY_VPI_PATH}/lib/*"].each do |lib|
	localPath = File.basename(lib)

	RUBY_LIBS[lib] = localPath
	CLEAN.include localPath
end


# propogate cleaning events to Ruby-VPI
[:clean, :clobber].each do |t|
	task t do
		cd RUBY_VPI_PATH do
			sh "rake #{t}"
		end
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


desc "Fetches available Ruby libraries from Ruby-VPI."
task :libs => RUBY_LIBS.keys do |t|
	RUBY_LIBS.each_pair do |src, dst|
		silentCopy src, dst
	end
end


desc "Simulate with Pragmatic C - Cver."
task :cver => 'cver:run'

namespace 'cver' do
	task :run => [:build, :libs, *SIMULATOR_SOURCES] do |t|
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
	task :run => [:build, :libs, *SIMULATOR_SOURCES] do |t|
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
	task :run => [:build, :libs, "#{RUBY_VPI_PATH}/examples/synopsys_vcs.tab", *SIMULATOR_SOURCES] do |t|
		require 'rbconfig'

		sh "vcs #{SIMULATOR_ARGS[:vcs]} -R +v2k +vpi -LDFLAGS '#{File.expand_path(NORMAL_OBJ_PATH)} -L#{Config::CONFIG['libdir']} #{Config::CONFIG['LIBRUBYARG']} -lpthread' -P #{t.prerequisites[2]} #{SIMULATOR_SOURCES_STRING}"
	end

	task :build do
		buildRubyVpi "-DSYNOPSYS_VCS"
	end

	CLEAN.include 'csrc', 'simv*'
end


desc "Simulate with Mentor Modelsim."
task :vsim => 'vsim:run'

namespace 'vsim' do
	task :run => [:build, :libs, *SIMULATOR_SOURCES] do |t|
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
