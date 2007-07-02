# A template to simplify building and running examples.  This
# file is meant to be embedded in another Rakefile, which bears
# the responsibility of defining the following variables.
#
# = Required variables
#
# SIMULATOR_SOURCES::   Array of paths to (1) source files or (2)
#                       directories that contain source files
#                       which must be loaded by the simulator.
#
# SIMULATOR_ARGUMENTS:: A hash table containing keys for each simulator task
#                       (same as Rakefile task names) and values containing
#                       command-line arguments for each simulator.
#
#--
# Copyright 2006-2007 Suraj N. Kurapati
# See the file named LICENSE for details.

# check for required variables
  vars = %w[SIMULATOR_SOURCES SIMULATOR_ARGUMENTS]

  unless vars.all? {|v| eval "defined? #{v}"}
    raise ArgumentError, "#{vars.join(' and ')} must be defined."
  end

# auto-detect and set default parameters
  runnerPath       = caller.reject {|s| s =~ /:in \`/}.first.sub(/:[^:]*$/, '')
  testName         = File.basename(runnerPath).sub(/_[^_]*$/, '')
  SIMULATOR_TARGET = testName + '_bench'

  task :setup
  SIMULATOR_INCLUDES = SIMULATOR_SOURCES.reject! {|s| File.directory? s} || []

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

# prepare hook for rb_load_file() in main.c
  ENV['RUBYVPI_BOOTSTRAP'] = SIMULATOR_TARGET + '.rb'


require 'rake/clean'
require 'ruby-vpi'
require 'ruby-vpi/rake'

include RubyVpi::Config

OBJECT_PATH = File.join(File.dirname(__FILE__), '..', '..', 'obj')
LOADER_FUNC = 'vlog_startup_routines_bootstrap'


# Returns the path to the Ruby-VPI object file for the given simulator.
def object_file_path aSimId # :nodoc:
  path = File.join(OBJECT_PATH, aSimId.to_s)

  unless File.exist? path
    raise "Object file #{path.inspect} is missing. Rebuild #{PROJECT_NAME}."
  end

  path
end

# Returns an array of include-directory options.
def expand_include_dir_options aSimId, aIncludes = SIMULATOR_INCLUDES # :nodoc:
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


desc "Simulate with #{SIMULATORS[:cver].name}."
task :cver => :setup do
  sh 'cver', SIMULATOR_ARGUMENTS[:cver], "+loadvpi=#{object_file_path(:cver)}:#{LOADER_FUNC}", expand_include_dir_options(:cver), SIMULATOR_SOURCES
end

CLOBBER.include 'verilog.log'


desc "Simulate with #{SIMULATORS[:ivl].name}."
task :ivl => :setup do
  cp object_file_path(:ivl), 'ruby-vpi.vpi'
  sh 'iverilog', SIMULATOR_ARGUMENTS[:ivl], '-mruby-vpi', expand_include_dir_options(:ivl), SIMULATOR_SOURCES
  sh 'vvp -M. a.out'
end

CLEAN.include 'ruby-vpi.vpi', 'a.out'


desc "Simulate with #{SIMULATORS[:vcs].name}."
task :vcs => :setup do
  sh %w(vcs -R +v2k +vpi), SIMULATOR_ARGUMENTS[:vcs], '-load', "#{object_file_path(:vcs)}:#{LOADER_FUNC}", expand_include_dir_options(:vcs), SIMULATOR_SOURCES
end

CLEAN.include 'csrc', 'simv*'


desc "Simulate with #{SIMULATORS[:vsim].name}."
task :vsim => :setup do
  sh 'vlib work'
  sh 'vlog', expand_include_dir_options(:vsim), SIMULATOR_SOURCES
  sh 'vsim', SIMULATOR_ARGUMENTS[:vsim], '-c', SIMULATOR_TARGET, '-pli', object_file_path(:vsim), '-do', 'run -all'
end

CLEAN.include 'work'
CLOBBER.include 'transcript'


desc "Simulate with #{SIMULATORS[:ncsim].name}."
task :ncsim => :setup do
  sh 'ncverilog', SIMULATOR_ARGUMENTS[:ncsim], "+loadvpi=#{object_file_path(:ncsim)}:#{LOADER_FUNC}", '+access+rwc', expand_include_dir_options(:ncsim), SIMULATOR_SOURCES
end

CLEAN.include 'INCA_libs'
CLOBBER.include 'ncverilog.log', 'ncsim.log'
