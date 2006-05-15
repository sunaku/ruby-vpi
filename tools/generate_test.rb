#!/usr/bin/env ruby
#
# == Synopsis
# Generates a Ruby-VPI test bench from Verilog 2001 module declarations.
#
# == Usage
# ruby generate_test.rb [option...] [input-file...]
#
# option::
# 	Specify "--help" to see a list of options.
#
# input-file::
# 	A source file which contains one or more Verilog 2001 module declarations.
#
# * If no input files are specified, then the standard input stream will be read instead.
# * The first signal parameter in a module's declaration is assumed to be the clocking signal.

=begin
	Copyright 2006 Suraj N. Kurapati

	This file is part of Ruby-VPI.

	Ruby-VPI is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

	Ruby-VPI is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
=end

require 'optparse'
require 'rdoc/usage'

OUTPUT_SUFFIX = '_test'.freeze
RUNNER_SUFFIX = '_runner'.freeze
DESIGN_SUFFIX = '_design'.freeze
SPEC_SUFFIX = '_spec'.freeze

SPEC_FORMATS = [:RSpec, :UnitTest, :Generic].freeze


# Removes the left indentation of the given output by the indentation of its first line.
def fixIndent aOutput
	aOutput =~ %r{\n+([\t ]+)}

	if indentation = $1
		aOutput.gsub %r{(\n+)#{indentation}}, '\1'
	end

	aOutput
end


# Generates and returns the content of the Verilog runner file, which cooperates with the Ruby runner file to run the test bench.
def generateVerilogRunner aModuleInfo, aOutputInfo

	# configuration parameters for design under test
	configDecl = aModuleInfo.paramDecls.inject('') do |acc, decl|
		acc << "parameter #{decl};\n"
	end


	# accessors for design under test interface
	portInitDecl = aModuleInfo.portDecls.inject('') do |acc, decl|
		{ 'input' => 'reg', 'output' => 'wire' }.each_pair do |key, val|
			decl.sub! %r{\b#{key}\b(.*?)$}, "#{val}\\1;"
		end

		decl.strip!
		acc << decl << "\n"
	end


	# instantiation for the design under test

		# creates a comma-separated string of parameter declarations in module instantiation format
		def makeInstParamDecl(paramNames)
			paramNames.inject([]) {|acc, param| acc << ".#{param}(#{param})"}.join(', ')
		end

	instConfigDecl = makeInstParamDecl(aModuleInfo.paramNames)
	instParamDecl = makeInstParamDecl(aModuleInfo.portNames)

	instDecl = "#{aModuleInfo.name} " << (
		unless instConfigDecl.empty?
			'#(' << instConfigDecl << ')'
		else
			''
		end
	) << " #{aOutputInfo.verilogRunnerName}#{DESIGN_SUFFIX} (#{instParamDecl});"


	clockSignal = aModuleInfo.portNames.first

	%{
		module #{aOutputInfo.verilogRunnerName};

			// configuration for the design under test
			#{configDecl}

			// accessors for the design under test
			#{portInitDecl}

			// instantiate the design under test
			#{instDecl}


			// interface to Ruby-VPI
			initial begin
				#{clockSignal} = 0;
				$ruby_init("-w", "#{aOutputInfo.rubyRunnerPath}"#{', "-f", "s"' if aOutputInfo.specFormat == :RSpec});
			end

			// generate a 50% duty-cycle clock for the design under test
			always begin
				#5 #{clockSignal} = ~#{clockSignal};
			end

			// transfer control to Ruby-VPI every clock cycle
			always @(posedge #{clockSignal}) begin
				$ruby_relay();
			end

		endmodule
	}
end

# Generates and returns the content of the Ruby runner file, which cooperates with the Verilog runner file to run the test bench.
def generateRubyRunner aModuleInfo, aOutputInfo
	%{
		require '#{aOutputInfo.specPath}'

		\# service the $ruby_init() callback
		Vpi::relay_verilog

		\# service the $ruby_relay() callback
		#{
			case aOutputInfo.specFormat
				when :UnitTest, :RSpec
					"\# #{aOutputInfo.specFormat} will take control from here."

				else
					aOutputInfo.specClassName + '.new'
			end
		}
	}
end

# Generates and returns the content of the Ruby design file, which is a Ruby abstraction of the Verilog module's interface.
def generateDesign aModuleInfo, aOutputInfo
	accessorDecl = aModuleInfo.portNames.inject([]) do |acc, param|
		acc << ":#{param}"
	end.join(', ')

	portInitDecl = aModuleInfo.portNames.inject('') do |acc, param|
		acc << %{@#{param} = Vpi::vpi_handle_by_name("#{aOutputInfo.verilogRunnerName}.#{param}", nil)\n}
	end

	%{
		# An interface to the design under test.
		class #{aOutputInfo.designClassName}
			attr_reader #{accessorDecl}

			def initialize
				#{portInitDecl}
			end
		end
	}
end

# Generates and returns the content of the Ruby specification file, which verifies the design under test.
def generateSpec aModuleInfo, aOutputInfo
	raise ArgumentError unless SPEC_FORMATS.include? aOutputInfo.specFormat

	accessorTestDecl = aModuleInfo.portNames.inject('') do |acc, param|
		acc << "def test_#{param}\nend\n\n"
	end

	%{
		\# A specification which verifies the design under test.
		require '#{aOutputInfo.designPath}'
		require 'vpi_util'
		#{
			case aOutputInfo.specFormat
				when :UnitTest
					"require 'test/unit'"

				when :RSpec
					"require 'rspec'"
			end
		}


		#{
			case aOutputInfo.specFormat
				when :UnitTest
					%{
						class #{aOutputInfo.specClassName} < Test::Unit::TestCase
							include Vpi

							def setup
								@design = #{aOutputInfo.designClassName}.new
							end

							#{accessorTestDecl}
						end
					}

				when :RSpec
					%{
						include Vpi

						context "A new #{aOutputInfo.designClassName}" do
							setup do
								@design = #{aOutputInfo.designClassName}.new
							end

							specify "should ..." do
								# @design.should ...
							end
						end
					}

				else
					%{
						class #{aOutputInfo.specClassName}
							include Vpi

							def initialize
								@design = #{aOutputInfo.designClassName}.new
							end
						end
					}
			end
		}
	}
end

# Holds information about a parsed Verilog module.
class ModuleInfo
	attr_reader :name, :portNames, :paramNames, :portDecls, :paramDecls

	def initialize aDecl
		aDecl =~ %r{module\s+(\w+)\s*(\#\((.*?)\))?\s*\((.*?)\)\s*;}
		@name, paramDecl, portDecl = $1, $3 || '', $4


		# parse configuration parameters
		paramDecl.gsub! %r{\bparameter\b}, ''
		paramDecl.strip!

		@paramDecls = paramDecl.split(/,/)

		@paramNames = paramDecls.inject([]) do |acc, decl|
			acc << decl.scan(%r{\w+}).first
		end


		# parse signal parameters
		portDecl.gsub! %r{\breg\b}, ''
		portDecl.strip!

		@portDecls = portDecl.split(/,/)

		@portNames = portDecls.inject([]) do |acc, decl|
			acc << decl.scan(%r{\w+}).last
		end
	end
end

# Holds information about the output destinations of a parsed Verilog module.
class OutputInfo
	attr_reader :verilogRunnerName, :verilogRunnerPath, :rubyRunnerName, :rubyRunnerPath, :designName, :designClassName, :designPath, :specName, :specClassName, :specFormat, :specPath

	def initialize aModuleName, aSpecFormat
		@verilogRunnerName = aModuleName + RUNNER_SUFFIX
		@verilogRunnerPath = @verilogRunnerName + '.v'

		@rubyRunnerName = aModuleName + RUNNER_SUFFIX
		@rubyRunnerPath = @rubyRunnerName + '.rb'

		@designName = aModuleName + DESIGN_SUFFIX
		@designPath = @designName + '.rb'

		@specName = aModuleName + SPEC_SUFFIX
		@specPath = @specName + '.rb'

		@designClassName = aModuleName.capitalize
		@specClassName = @specName.capitalize

		@specFormat = aSpecFormat
	end
end


# parse command-line options
$specFormat = :Generic

optsParser = OptionParser.new
optsParser.on('-h', '--help', 'show this help message') {raise}
optsParser.on('-u', '--unit', 'optimize for Test::Unit') {|v| $specFormat = :UnitTest if v}
optsParser.on('-s', '--spec', 'optimize for RSpec') {|v| $specFormat = :RSpec if v}

begin
	optsParser.parse!(ARGV)
rescue
	puts optsParser
	RDoc::usage
end

puts "output is optimized for #{$specFormat}"


# sanitize the input
input = ARGF.read

	# remove single-line comments
	input.gsub! %r{//.*$}, ''

	# collapse the input into a single line
	input.tr! "\n", ''

	# remove multi-line comments
	input.gsub! %r{/\*.*?\*/}, ''


# parse the input
input.scan(%r{module.*?;}).each do |moduleDecl|
	m = ModuleInfo.new(moduleDecl).freeze
	puts "parsed #{m.name}"


	# generate output
	o = OutputInfo.new(m.name, $specFormat).freeze

	File.open(o.verilogRunnerPath, "w") do |f|
		f << generateVerilogRunner(m, o)
	end
	puts "generated #{o.verilogRunnerPath}"

	File.open(o.rubyRunnerPath, "w") do |f|
		f << generateRubyRunner(m, o)
	end
	puts "generated #{o.rubyRunnerPath}"

	File.open(o.designPath, "w") do |f|
		f << generateDesign(m, o)
	end
	puts "generated #{o.designPath}"

	File.open(o.specPath, "w") do |f|
		f << generateSpec(m, o)
	end
	puts "generated #{o.specPath}"
end
