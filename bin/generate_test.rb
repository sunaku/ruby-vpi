#!/usr/bin/ruby -w
# Generates Ruby-VPI tests from Verilog 2001 module declarations.
# * If no input files are specified, then the standard input stream is assumed to be the input.
# * The first input signal in a module's declaration is assumed to be the clocking signal.
# * Existing output files will be backed-up before being over-written. A backed-up file has a tilde (~) appended to its name.

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

# Writes the given contents to the file at the given path. If the given path already exists, then a backup is created before proceeding.
def write_file aPath, aContent
  # create a backup
    if File.exist? aPath
      backupPath = aPath.dup

      while File.exist? backupPath
        backupPath << '~'
      end

      FileUtils.cp aPath, backupPath, :preserve => true
    end

  File.open(aPath, 'w') {|f| f << aContent}
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

  SPEC_FORMATS = [:RSpec, :UnitTest, :Generic]

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

    optSpecFmt = :Generic
    optTestName = 'test'

    opts = OptionParser.new
    opts.banner = "Usage: #{File.basename __FILE__} [options] [files]"

    opts.on '-h', '--help', 'show this help message' do
      require 'ruby-vpi/rdoc'
      RDoc.usage_from_file __FILE__

      puts opts
      exit
    end

    opts.on '-u', '--unit', 'use Test::Unit specification format' do |val|
      optSpecFmt = :UnitTest if val
    end

    opts.on '-r', '--rspec', 'use RSpec specification format' do |val|
      optSpecFmt = :RSpec if val
    end

    opts.on '-n', '--name NAME', 'attach NAME indentifier to generated test' do |val|
      optTestName = val
    end

    opts.parse! ARGV

  puts "Using name #{optTestName.inspect} for generated test."
  puts "Using #{optSpecFmt} specification format."


  v = VerilogParser.new(ARGF.read)

  v.modules.each do |m|
    puts '', "Parsed module: #{m.name}"

    o = OutputInfo.new(m.name, optSpecFmt, optTestName, File.dirname(File.dirname(__FILE__))).freeze

    # generate output
      aParseInfo, aModuleInfo, aOutputInfo = v, m, o

      write_file o.runnerPath, RUNNER_TEMPLATE.result(binding)
      puts "- Generated runner:           #{o.runnerPath}"

      write_file o.verilogBenchPath, VERILOG_BENCH_TEMPLATE.result(binding)
      puts "- Generated bench:            #{o.verilogBenchPath}"

      write_file o.rubyBenchPath, RUBY_BENCH_TEMPLATE.result(binding)
      puts "- Generated bench:            #{o.rubyBenchPath}"

      write_file o.designPath, DESIGN_TEMPLATE.result(binding)
      puts "- Generated design:           #{o.designPath}"

      write_file o.protoPath, PROTO_TEMPLATE.result(binding)
      puts "- Generated prototype:        #{o.protoPath}"

      write_file o.specPath, SPEC_TEMPLATE.result(binding)
      puts "- Generated specification:    #{o.specPath}"
  end
end
