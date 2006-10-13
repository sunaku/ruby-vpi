# A template to simplify building and running examples. This file is meant to be embedded in another Rakefile, which bears the responsibility of defining the following variables.
#
# = Required variables
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

# check for required variables
  raise ArgumentError, "Required variables are undefined." unless
    defined?(SIMULATOR_SOURCES) &&
    defined?(SIMULATOR_TARGET) &&
    defined?(SIMULATOR_ARGS)


require 'rake/clean'
require 'ruby-vpi/rake'

LIBRARY_PATH = File.join(File.dirname(__FILE__), '..')
OBJECT_PATH = File.join(LIBRARY_PATH, '..', 'obj')

# make Ruby-VPI libraries available to spec
  ENV['RUBYLIB'] = "#{ENV['RUBYLIB'] || ''}:#{LIBRARY_PATH}"


# Returns the path to the Ruby-VPI object file for the given simulator.
def object_file_path aSimId, aShared = false
  path = File.join(OBJECT_PATH, "ruby-vpi.#{aSimId}.#{aShared ? 'so' : 'o'}")
  raise "Object file #{path.inspect} is missing.\n Rebuild Ruby-VPI to generate the missing file." unless File.exist? path
  path
end

task :default do
  Rake.application.options.show_task_pattern = //
  Rake.application.display_tasks_and_comments
end


desc "Simulate with GPL Cver."
task :cver => SIMULATOR_SOURCES do |t|
  sh 'cver', SIMULATOR_ARGS[t.name.to_sym], "+loadvpi=#{object_file_path(t.name.to_sym, true)}:vlog_startup_routines_bootstrap", SIMULATOR_SOURCES
end

CLOBBER.include 'verilog.log'


desc "Simulate with Icarus Verilog."
task :ivl => SIMULATOR_SOURCES do |t|
  cp object_file_path(t.name.to_sym, true), 'ruby-vpi.vpi'
  sh 'iverilog', SIMULATOR_ARGS[t.name.to_sym], %w(-y. -mruby-vpi), SIMULATOR_SOURCES
  sh 'vvp -M. a.out'
end

CLEAN.include 'ruby-vpi.vpi', 'a.out'


desc "Simulate with Synopsys VCS."
task :vcs => collect_args(File.join(File.dirname(__FILE__), 'synopsys_vcs.tab'), SIMULATOR_SOURCES) do |t|
  require 'rbconfig'

  sh 'vcs', SIMULATOR_ARGS[t.name.to_sym], %w(-R +v2k +vpi -LDFLAGS), File.expand_path(object_file_path(t.name.to_sym)), "-L#{Config::CONFIG['libdir']}", Config::CONFIG['LIBRUBYARG'], %w(-lpthread -P), t.prerequisites[1], SIMULATOR_SOURCES
end

CLEAN.include 'csrc', 'simv*'


desc "Simulate with Mentor Modelsim."
task :vsim => SIMULATOR_SOURCES do |t|
  sh "vlib work"
  sh 'vlog', SIMULATOR_ARGS[t.name.to_sym], SIMULATOR_SOURCES
  sh 'vsim', '-c', SIMULATOR_TARGET, '-pli', object_file_path(t.name.to_sym, true), '-do', 'run -all'
end

CLEAN.include 'work'
CLOBBER.include 'transcript'
