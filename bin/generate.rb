# Generates Ruby-VPI tests from Verilog 2001 and Verilog 95 module declarations.
#
# * The standard input stream is read if no input files are specified.
#
# = Progress indicators
#
# module:: A Verilog module has been identified.
#
# create:: A file is being created because it does not exist.
#
# skip:: A file is being skipped because it is already up to date.
#
# update::  A file will be updated because it is out of date.  A text
#           merging tool (see MERGER) will be launched to transfer
#           content from the old file (*.old) and the new file (*.new)
#           to the out of date file.  If a text merging tool is not
#           specified, then you will have to do the merging by hand.
#
#
# = Environment variables
#
# MERGER::  A command that invokes a text merging tool with three
#           arguments: (1) old file, (2) new file, (3) output file.
#           The tool's output should be written to the output file.

#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

$: << File.join(File.dirname(__FILE__), '..', 'lib')

require 'ruby-vpi' # for project info
require 'ruby-vpi/verilog_parser'
require 'fileutils'
require 'digest/sha1'


# Notify the user about some action being performed.
def notify *args # :nodoc:
  printf "%8s  %s\n", *args
end

# Writes the given contents to the file at the given path. If the given path
# already exists, then a backup is created before invoking the merging tool.
def write_file aPath, aContent # :nodoc:
  if File.exist? aPath
    oldDigest = Digest::SHA1.digest(File.read(aPath))
    newDigest = Digest::SHA1.digest(aContent)

    if oldDigest == newDigest
      notify :skip, aPath
    else
      notify :update, aPath
      cur, old, new = aPath, "#{aPath}.old", "#{aPath}.new"

      FileUtils.cp cur, old, :preserve => true
      File.open(new, 'w') {|f| f << aContent}

      if m = ENV['MERGER']
        system "#{m} #{old.inspect} #{new.inspect} #{cur.inspect}"
      end
    end
  else
    notify :create, aPath
    File.open(aPath, 'w') {|f| f << aContent}
  end
end


require 'ruby-vpi/erb'

# Template used for generating output.
class Template < ERB # :nodoc:
  TEMPLATE_PATH = __FILE__.sub(/\.rb$/, '')

  def initialize aName
    super File.read(File.join(TEMPLATE_PATH, aName))
  end
end


# Holds information about the output destinations of a parsed Verilog module.
class OutputInfo # :nodoc:
  RUBY_EXT      = '.rb'
  VERILOG_EXT   = '.v'
  RAKE_EXT      = '.rake'

  DESIGN_SUFFIX = '_design'
  SPEC_SUFFIX   = '_spec'
  RUNNER_SUFFIX = '_runner'
  PROTO_SUFFIX  = '_proto'
  LOADER_SUFFIX = '_loader'

  SPEC_FORMATS = [:rSpec, :tSpec, :xUnit, :generic]

  attr_reader :designPath,  :designName,
              :specPath,    :specName,    :specClassName,    :specFormat,
              :runnerPath,  :runnerName,
              :protoPath,   :protoName,
              :loaderPath,  :loaderName

  def initialize aModuleName, aSpecFormat
    raise ArgumentError unless SPEC_FORMATS.include? aSpecFormat
    @specFormat    = aSpecFormat

    @designName    = aModuleName + DESIGN_SUFFIX
    @designPath    = @designName + RUBY_EXT

    @protoName     = aModuleName + PROTO_SUFFIX
    @protoPath     = @protoName  + RUBY_EXT

    @specName      = aModuleName + SPEC_SUFFIX
    @specPath      = @specName   + RUBY_EXT
    @specClassName = @specName.to_ruby_const_name

    @runnerName    = aModuleName + RUNNER_SUFFIX
    @runnerPath    = @runnerName + RAKE_EXT

    @loaderName    = aModuleName + LOADER_SUFFIX
    @loaderPath    = @loaderName + RUBY_EXT
  end
end


# obtain templates for output generation
  DESIGN_TEMPLATE = Template.new('design.rb')
  PROTO_TEMPLATE  = Template.new('proto.rb')
  SPEC_TEMPLATE   = Template.new('spec.rb')
  RUNNER_TEMPLATE = Template.new('runner.rake')
  LOADER_TEMPLATE = Template.new('loader.rb')


# parse command-line options
  require 'optparse'

  optSpecFmt  = :generic
  optTestName = 'test'

  opts        = OptionParser.new
  opts.banner = "Usage: ruby-vpi generate [options] [files]"

  opts.on '-h', '--help', 'show this help message' do
            require 'ruby-vpi/rdoc'
            RDoc.usage_from_file __FILE__

            puts opts
            exit
          end

  opts.on '--xUnit',
          'use xUnit (Test::Unit) specification format' do
            optSpecFmt = :xUnit
          end

  opts.on '--rSpec',
          'use rSpec specification format' do
            optSpecFmt = :rSpec
          end

  opts.on '--tSpec',
          'use test/spec specification format' do
            optSpecFmt = :tSpec
          end

  opts.parse! ARGV


v = VerilogParser.new(ARGF.read)
v.modules.each do |m|
  puts
  notify :module, m.name

  o = OutputInfo.new(m.name, optSpecFmt)
  aParseInfo, aModuleInfo, aOutputInfo = v.freeze, m.freeze, o.freeze

  write_file o.runnerPath, RUNNER_TEMPLATE.result(binding)
  write_file o.designPath, DESIGN_TEMPLATE.result(binding)
  write_file o.protoPath, PROTO_TEMPLATE.result(binding)
  write_file o.specPath, SPEC_TEMPLATE.result(binding)
  write_file o.loaderPath, LOADER_TEMPLATE.result(binding)
  write_file 'Rakefile', "require 'ruby-vpi/runner_proxy'"
end
