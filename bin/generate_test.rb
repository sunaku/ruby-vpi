#!/usr/bin/ruby -w
# Generates Ruby-VPI tests from Verilog 2001 module declarations.
# * The standard input stream is read if no input files are specified.
# * The first input signal in a module's declaration is assumed to be the clocking signal.
#
# = Progress indicators
# module:: A Verilog module has been identified.
# create:: A file is being created because it does not exist.
# skip:: A file is being skipped because it is already up to date.
# update:: A file will be updated because it is out of date. A text merging tool (see MERGER) will be launched to transfer content from the old file (*.old) and the new file (*.new) to the out of date file. If a text merging tool is not specified, then you will have to do the merging by hand.
#
# = Environment variables
# MERGER:: A command that invokes a text merging tool with three arguments: (1) old file, (2) new file, (3) output file. The tool's output should be written to the output file.


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

require 'ruby-vpi/verilog_parser'
require 'fileutils'
require 'digest/md5'


# Notify the user about some action being performed.
def notify *args # :nodoc:
  printf "%8s  %s\n", *args
end

# Writes the given contents to the file at the given path. If the given path already exists, then a backup is created before invoking the merging tool.
def write_file aPath, aContent # :nodoc:
  if File.exist? aPath
    oldDigest = Digest::MD5.digest(File.read(aPath))
    newDigest = Digest::MD5.digest(aContent)

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
  TEMPLATE_PATH = __FILE__.sub %r{\.rb$}, '_tpl'

  def initialize aName
    super File.read(File.join(TEMPLATE_PATH, aName))
  end
end



# Holds information about the output destinations of a parsed Verilog module.
class OutputInfo # :nodoc:
  RUBY_EXT = '.rb'
  VERILOG_EXT = '.v'
  RUNNER_EXT = '.rake'

  SPEC_FORMATS = [:rSpec, :tSpec, :xUnit, :generic]

  attr_reader :verilogBenchName, :verilogBenchPath, :rubyBenchName, :rubyBenchPath, :designName, :designClassName, :designPath, :specName, :specClassName, :specFormat, :specPath, :rubyVpiPath, :runnerName, :runnerPath, :protoName, :protoPath

  attr_reader :testName, :suffix, :benchSuffix, :designSuffix, :specSuffix, :runnerSuffix, :protoSuffix

  def initialize aModuleName, aSpecFormat, aTestName, aRubyVpiPath
    raise ArgumentError unless SPEC_FORMATS.include? aSpecFormat
    @specFormat = aSpecFormat
    @testName = aTestName

    @suffix = '_' + @testName
    @benchSuffix = @suffix + '_bench'
    @designSuffix = @suffix + '_design'
    @specSuffix = @suffix + '_spec'
    @runnerSuffix = @suffix + '_runner'
    @protoSuffix = @suffix + '_proto'

    @rubyVpiPath = aRubyVpiPath

    @verilogBenchName = aModuleName + @benchSuffix
    @verilogBenchPath = @verilogBenchName + VERILOG_EXT

    @rubyBenchName = aModuleName + @benchSuffix
    @rubyBenchPath = @rubyBenchName + RUBY_EXT

    @designName = aModuleName + @designSuffix
    @designPath = @designName + RUBY_EXT

    @protoName = aModuleName + @protoSuffix
    @protoPath = @protoName + RUBY_EXT

    @specName = aModuleName + @specSuffix
    @specPath = @specName + RUBY_EXT

    @designClassName = aModuleName.to_ruby_const_name
    @specClassName = @specName.to_ruby_const_name

    @runnerName = aModuleName + @runnerSuffix
    @runnerPath = @runnerName + RUNNER_EXT
  end
end



if File.basename($0) == File.basename(__FILE__)
  # obtain templates for output generation
    VERILOG_BENCH_TEMPLATE = Template.new('bench.v')
    RUBY_BENCH_TEMPLATE = Template.new('bench.rb')
    DESIGN_TEMPLATE = Template.new('design.rb')
    PROTO_TEMPLATE = Template.new('proto.rb')
    SPEC_TEMPLATE = Template.new('spec.rb')
    RUNNER_TEMPLATE = Template.new('runner.rake')


  # parse command-line options
    require 'optparse'

    optSpecFmt = :generic
    optTestName = 'test'

    opts = OptionParser.new
    opts.banner = "Usage: #{File.basename __FILE__} [options] [files]"

    opts.on '-h', '--help', 'show this help message' do
      require 'ruby-vpi/rdoc'
      RDoc.usage_from_file __FILE__

      puts opts
      exit
    end

    opts.on '--xunit', '--test-unit', 'use xUnit (Test::Unit) specification format' do |val|
      optSpecFmt = :xUnit if val
    end

    opts.on '--rspec', 'use rSpec specification format' do |val|
      optSpecFmt = :rSpec if val
    end

    opts.on '--tspec', '--test-spec', 'use test/spec specification format' do |val|
      optSpecFmt = :tSpec if val
    end

    opts.on '-n', '--name NAME', 'insert NAME into the names of generated files' do |val|
      optTestName = val
    end

    opts.parse! ARGV


  v = VerilogParser.new(ARGF.read)

  v.modules.each do |m|
    puts
    notify :module, m.name

    o = OutputInfo.new(m.name, optSpecFmt, optTestName, File.dirname(File.dirname(__FILE__)))

    # generate output
      aParseInfo, aModuleInfo, aOutputInfo = v.freeze, m.freeze, o.freeze

      write_file o.runnerPath, RUNNER_TEMPLATE.result(binding)
      write_file o.verilogBenchPath, VERILOG_BENCH_TEMPLATE.result(binding)
      write_file o.rubyBenchPath, RUBY_BENCH_TEMPLATE.result(binding)
      write_file o.designPath, DESIGN_TEMPLATE.result(binding)
      write_file o.protoPath, PROTO_TEMPLATE.result(binding)
      write_file o.specPath, SPEC_TEMPLATE.result(binding)
  end
end
