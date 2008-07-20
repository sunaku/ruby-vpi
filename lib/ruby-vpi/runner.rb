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
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

require 'ruby-vpi/util'

# go into same directory as the test runner file
  if RUBY_VERSION =~ /^1\.9\./
    path = caller.grep(/:in `require'/).first
  else
    path = caller.reject {|s| s =~ /:in /}.first
  end

  if path
    dir = File.dirname path[/^[^:]*/]
    cd dir unless Rake.original_dir == dir
  end

# check for required variables
  vars = %w[TEST_LOADER SIMULATOR_SOURCES SIMULATOR_ARGUMENTS]

  unless vars.all? {|v| eval "defined? #{v}"}
    raise ArgumentError, "#{vars.join(' and ')} must be defined."
  end

  raise ArgumentError, "The path specified by TEST_LOADER does not exist: #{TEST_LOADER.inspect}" unless File.exist? TEST_LOADER
  raise ArgumentError, "The path specified by TEST_LOADER does not refer to a file: #{TEST_LOADER.inspect}" unless File.file? TEST_LOADER
  raise ArgumentError, "The path specified by TEST_LOADER is not readable: #{TEST_LOADER.inspect}" unless File.readable? TEST_LOADER

# resolve paths to sources by searching include directories
  @sources = SIMULATOR_SOURCES.to_a.uniq
  @incdirs = @sources.select {|s| File.directory? s}
  @sources -= @incdirs

  @sources.map! do |src|
    unless File.exist? src
      @incdirs.each do |dir|
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
ENV['RUBYVPI_TEST_LOADER'] = TEST_LOADER

# check if the machine is 64-bit
@archIs64 = 0.size == 8


require 'rake/clean'
require 'ruby-vpi'
require 'ruby-vpi/rake'

OBJECT_PATH = File.join(File.dirname(__FILE__), '..', '..', 'obj')
LOADER_FUNC = 'vlog_startup_routines_bootstrap'


# Returns the path to the Ruby-VPI object file for the given simulator.
def object_file_path aSimId # :nodoc:
  path = File.expand_path File.join(OBJECT_PATH, "#{aSimId}.so")

  unless File.exist? path
    raise "Object file #{path.inspect} is missing. Rebuild Ruby-VPI."
  end

  path
end

# Returns an array of include-directory options.
def expand_incdir_options aSimId # :nodoc:
  prefix = aSimId == :ivl ? '-I' : '+incdir+'
  @incdirs.map {|i| prefix + i}
end

# Creates a new task for running the given simulator.
def sim_task aSimId #:nodoc:
  desc "Simulate with #{RubyVPI::SIMULATORS.find_by_id(aSimId).name}."
  task aSimId => :setup do
    ENV['RUBYVPI_SIMULATOR'] = aSimId.to_s
    yield aSimId
  end
end


desc "User-defined task that is invoked before the simulator runs."
task :setup


desc "Show a list of available tasks."
task :default do
  Rake.application.options.show_task_pattern = //
  Rake.application.display_tasks_and_comments
end


sim_task :cver do |id|
  sh 'cver',
    "+loadvpi=#{object_file_path(id)}:#{LOADER_FUNC}",
    SIMULATOR_ARGUMENTS[id],
    expand_incdir_options(id),
    @sources
end

CLOBBER.include 'verilog.log'


sim_task :ivl do |id|
  cp object_file_path(id), 'ruby-vpi.vpi'
  sh %w[iverilog -mruby-vpi],
    SIMULATOR_ARGUMENTS[id],
    expand_incdir_options(id),
    @sources
  sh 'vvp -M. a.out'
end

CLEAN.include 'ruby-vpi.vpi', 'a.out'


sim_task :vcs do |id|
  sh %w[vcs -R +v2k +vpi +cli],
    '-P', File.join(File.dirname(__FILE__), 'pli.tab'),
    '-load', "#{object_file_path(id)}:#{LOADER_FUNC}",
    ('-full64' if @archIs64),
    SIMULATOR_ARGUMENTS[id],
    expand_incdir_options(id),
    @sources
end

CLEAN.include 'csrc', 'simv*'


sim_task :vsim do |id|
  sh 'vlib work'
  sh 'vlog', expand_incdir_options(id), @sources
  sh %w[vsim -c],
    '-do', 'run -all; exit',
    '-pli', object_file_path(id),
    SIMULATOR_ARGUMENTS[id]
end

CLEAN.include 'work', 'vsim.wlf'
CLOBBER.include 'transcript'


sim_task :ncsim do |id|
  sh %w[ncverilog +access+rwc +plinowarn],
    "+loadvpi=#{object_file_path(id)}:#{LOADER_FUNC}",
    ('+nc64bit' if @archIs64),
    SIMULATOR_ARGUMENTS[id],
    expand_incdir_options(id),
    @sources
end

CLEAN.include 'INCA_libs'
CLOBBER.include 'ncverilog.log', 'ncsim.log'
