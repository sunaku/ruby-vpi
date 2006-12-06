# A template to simplify building and running examples. This file is meant to be embedded in another Rakefile, which bears the responsibility of defining the following variables.
#
# = Required variables
# SIMULATOR_SOURCES:: Array of paths to source files needed by the simulator.
# SIMULATOR_TARGET:: Name of the Verilog module to be simulated.
# SIMULATOR_ARGS:: A hash containing keys for each simulator task (same as Rakefile task names) and values containing command-line arguments for each simulator.

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
  raise ArgumentError, "All required variables must be defined." unless
    defined?(SIMULATOR_SOURCES) &&
    defined?(SIMULATOR_TARGET) &&
    defined?(SIMULATOR_ARGS)

  SIMULATOR_INCLUDES = [] unless defined? SIMULATOR_INCLUDES

  task :setup

# resolve paths to sources by searching include directories
  SIMULATOR_SOURCES.map! do |src|
    unless File.exist? src
      SIMULATOR_INCLUDES.each do |dir|
        path = File.join(dir, src)

        if File.exist? path
          src = path
          break
        end
      end
    end

    src
  end


require 'rake/clean'
require 'ruby-vpi'
require 'ruby-vpi/rake'

include RubyVpi::Config

OBJECT_PATH = File.join(File.dirname(__FILE__), '..', '..', 'obj')
BOOTSTAP_FUNC = 'vlog_startup_routines_bootstrap'


# Returns the path to the Ruby-VPI object file for the given simulator.
def object_file_path aSimId
  path = File.join(OBJECT_PATH, "#{PROJECT_ID}.#{aSimId}.so")

  unless File.exist? path
    raise "Object file #{path.inspect} is missing. Rebuild #{PROJECT_NAME}."
  end

  path
end

# Returns an array of include-directory options.
def expand_include_dir_options aSimId, aIncludes = SIMULATOR_INCLUDES
  prefix = case aSimId
    when :ivl
      '-I'

    else
      '+incdir+'
  end

  aIncludes.map {|i| prefix + i}
end


desc "Show a list of available tasks."
task :default do
  Rake.application.options.show_task_pattern = //
  Rake.application.display_tasks_and_comments
end


desc "Simulate with GPL Cver."
task :cver => :setup do
  sh 'cver', SIMULATOR_ARGS[:cver], "+loadvpi=#{object_file_path(:cver)}:#{BOOTSTAP_FUNC}", expand_include_dir_options(:cver), SIMULATOR_SOURCES
end

CLOBBER.include 'verilog.log'


desc "Simulate with Icarus Verilog."
task :ivl => :setup do
  cp object_file_path(:ivl), 'ruby-vpi.vpi'
  sh 'iverilog', SIMULATOR_ARGS[:ivl], '-mruby-vpi', expand_include_dir_options(:ivl), SIMULATOR_SOURCES
  sh 'vvp -M. a.out'
end

CLEAN.include 'ruby-vpi.vpi', 'a.out'


desc "Simulate with Synopsys VCS."
task :vcs => :setup do
  sh %w(vcs -R +v2k +vpi), SIMULATOR_ARGS[:vcs], '-load', "#{object_file_path(:vcs)}:#{BOOTSTAP_FUNC}", expand_include_dir_options(:vcs), SIMULATOR_SOURCES
end

CLEAN.include 'csrc', 'simv*'


desc "Simulate with Mentor Modelsim."
task :vsim => :setup do
  sh 'vlib work'
  sh 'vlog', expand_include_dir_options(:vsim), SIMULATOR_SOURCES
  sh 'vsim', SIMULATOR_ARGS[:vsim], '-c', SIMULATOR_TARGET, '-pli', object_file_path(:vsim), '-do', 'run -all'
end

CLEAN.include 'work'
CLOBBER.include 'transcript'
