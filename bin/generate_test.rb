#!/usr/bin/ruby -w
# Generates Ruby-VPI tests from Verilog 2001 module declarations.
# * The standard input stream is read if no input files are specified.
# * The first input signal in a module's declaration is assumed to be the clocking signal.
#
# = Progress indicators
# create:: File will be created because it does not exist.
# skip:: File will be skipped because it is already up to date.
# update:: File will be updated because it is out of date. A backup copy will be made before the file is updated. Use a text merging tool (see MERGER) or manually transfer any necessary information from the backup copy to the updated file.
# backup:: A backup copy of a file is being made.
#
# = Environment variables
# MERGER:: A command that invokes a text merging tool with two arguments: old file, new file. The tool's output should be written to the new file.


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
def notify *args
  printf "%8s  %s\n", *args
end

# Writes the given contents to the file at the given path. If the given path already exists, then a backup is created before invoking the merging tool.
def write_file aPath, aContent
  if File.exist? aPath
    oldDigest = Digest::MD5.digest(File.read(aPath))
    newDigest = Digest::MD5.digest(aContent)

    if oldDigest == newDigest
      notify :skip, aPath
    else
      old, new = "#{aPath}.old", aPath

      notify :backup, old
      FileUtils.cp aPath, old, :preserve => true

      notify :update, aPath
      File.open(new, 'w') {|f| f << aContent}

      if m = ENV['MERGER']
        system "#{m} #{old.inspect} #{new.inspect}"
      end
    end
  else
    notify :create, aPath
    File.open(aPath, 'w') {|f| f << aContent}
  end
end


require 'ruby-vpi/erb'

# Template used for generating output.
class Template < ERB
  TEMPLATE_PATH = __FILE__.sub %r{\.rb$}, '_tpl'

  def initialize aName
    super File.read(File.join(TEMPLATE_PATH, aName))
  end
end



# Holds information about the output destinations of a parsed Verilog module.
class OutputInfo
  RUBY_EXT = '.rb'
  VERILOG_EXT = '.v'
  RUNNER_EXT = '.rake'

  SPEC_FORMATS = [:rSpec, :xUnit, :generic]

  attr_reader :verilogBenchName, :verilogBenchPath, :rubyBenchName, :rubyBenchPath, :designName, :designClassName, :designPath, :specName, :specClassName, :specFormat, :specPath, :rubyVpiPath, :runnerName, :runnerPath, :protoName, :protoPath, :protoClassName

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
    @protoClassName = @designClassName + 'Prototype'
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

    opts.on '--xunit', 'use xUnit specification format' do |val|
      optSpecFmt = :xUnit if val
    end

    opts.on '--rspec', 'use rSpec specification format' do |val|
      optSpecFmt = :rSpec if val
    end

    opts.on '-n', '--name NAME', 'attach NAME indentifier to generated test' do |val|
      optTestName = val
    end

    opts.parse! ARGV

    notify :name, optTestName
    notify :format, optSpecFmt


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
