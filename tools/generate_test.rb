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
# aParamDecls:: An array containing declarations of module parameters.
# aPortDecls:: An array containing declarations of module ports.
def generateVerilogRunner aModuleName, aVerilogRunnerName, aParamNames, aParamDecls, aPortNames, aPortDecls, aRubyRunnerPath, aSpecFormat

	# configuration parameters for design under test
	configDecl = aParamDecls.inject('') do |acc, decl|
		acc << "parameter #{decl};\n"
	end


	# accessors for design under test interface
	portInitDecl = aPortDecls.inject('') do |acc, decl|
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

	instConfigDecl = makeInstParamDecl(aParamNames)
	instParamDecl = makeInstParamDecl(aPortNames)

	instDecl = "#{aModuleName} " << (
		unless instConfigDecl.empty?
			'#(' << instConfigDecl << ')'
		else
			''
		end
	) << " #{aVerilogRunnerName}#{DESIGN_SUFFIX} (#{instParamDecl});"


	clockSignal = aPortNames.first

	%{
		module #{aVerilogRunnerName};

			// configuration for the design under test
			#{configDecl}

			// accessors for the design under test
			#{portInitDecl}

			// instantiate the design under test
			#{instDecl}


			// interface to Ruby-VPI
			initial begin
				#{clockSignal} = 0;
				$ruby_init("-w", "#{aRubyRunnerPath}"#{', "-f", "s"' if aSpecFormat == :RSpec});
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
# aPortNames:: An array containing names of module port variables. The first of these is assumed to be the clocking signal.
# aRubyDesignPath:: File to the Ruby design file.
# aRubySpecPath:: File to the Ruby specification file.
def generateRubyRunner aSpecFormat, aPortNames, aRubySpecClassName, aRubySpecPath
	%{
		require '#{aRubySpecPath}'

		\# service the $ruby_init() callback
		Vpi::relay_verilog

		\# service the $ruby_relay() callback
		#{
			case aSpecFormat
				when :UnitTest, :RSpec
					"\# #{aSpecFormat} will take control from here."

				else
					aRubySpecClassName + '.new'
			end
		}
	}
end

# Generates and returns the content of the Ruby design file, which is a Ruby abstraction of the Verilog module's interface.
# aModuleName:: Name of the Verilog module.
# aPortNames:: An array containing names of module ports.
def generateRubyDesign aRubyDesignClassName, aPortNames, aVerilogRunnerName
	accessorDecl = aPortNames.inject([]) do |acc, param|
		acc << ":#{param}"
	end.join(', ')

	portInitDecl = aPortNames.inject('') do |acc, param|
		acc << %{@#{param} = Vpi::vpi_handle_by_name("#{aVerilogRunnerName}.#{param}", nil)\n}
	end

	%{
		# An interface to the design under test.
		class #{aRubyDesignClassName}
			attr_reader #{accessorDecl}

			def initialize
				#{portInitDecl}
			end
		end
	}
end

# Generates and returns the content of the Ruby specification file, which verifies the design under test.
# aSpecFormat:: Format in which the output should be generated. See +SPEC_FORMATS+.
def generateRubySpec aSpecFormat, aRubyDesignClassName, aRubySpecClassName, aRubyDesignPath, aPortNames
	raise ArgumentError unless SPEC_FORMATS.include? aSpecFormat

	accessorTestDecl = aPortNames.inject('') do |acc, param|
		acc << "def test_#{param}\nend\n\n"
	end

	%{
		\# A specification which verifies the design under test.
		require '#{aRubyDesignPath}'
		require 'vpi_util'
		#{
			case aSpecFormat
				when :UnitTest
					"require 'test/unit'"

				when :RSpec
					"require 'rspec'"
			end
		}


		#{
			case aSpecFormat
				when :UnitTest
					%{
						class #{aRubySpecClassName} < Test::Unit::TestCase
							include Vpi

							def setup
								@design = #{aRubyDesignClassName}.new
							end

							#{accessorTestDecl}
						end
					}

				when :RSpec
					%{
						include Vpi

						context "A new #{aRubyDesignClassName}" do
							setup do
								@design = #{aRubyDesignClassName}.new
							end

							specify "should ..." do
								# @design.should ...
							end
						end
					}

				else
					%{
						class #{aRubySpecClassName}
							include Vpi

							def initialize
								@design = #{aRubyDesignClassName}.new
							end
						end
					}
			end
		}
	}
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

	moduleDecl =~ %r{module\s+(\w+)\s*(\#\((.*?)\))?\s*\((.*?)\)\s*;}
	moduleName, moduleParamDecl, modulePortDecl = $1, $3 || '', $4	# TODO: ports optional


	# parse configuration parameters
	moduleParamDecl.gsub! %r{\bparameter\b}, ''
	moduleParamDecl.strip!

	moduleParamDecls = moduleParamDecl.split(/,/)

	moduleParamNames = moduleParamDecls.inject([]) do |acc, decl|
		acc << decl.scan(%r{\w+}).first
	end


	# parse signal parameters
	modulePortDecl.gsub! %r{\breg\b}, ''
	modulePortDecl.strip!

	modulePortDecls = modulePortDecl.split(/,/)

	modulePortNames = modulePortDecls.inject([]) do |acc, decl|
		acc << decl.scan(%r{\w+}).last
	end


	puts "parsed #{moduleName}"



	# determine output destinations
	verilogRunnerName = moduleName + RUNNER_SUFFIX
	verilogRunnerPath = verilogRunnerName + '.v'

	rubyRunnerName = moduleName + RUNNER_SUFFIX
	rubyRunnerPath = rubyRunnerName + '.rb'

	rubyDesignName = moduleName + DESIGN_SUFFIX
	rubyDesignPath = rubyDesignName + '.rb'

	rubySpecName = moduleName + SPEC_SUFFIX
	rubySpecPath = rubySpecName + '.rb'

	designClassName = moduleName.capitalize
	specClassName = rubySpecName.capitalize


	# generate output
	File.open(verilogRunnerPath, "w") do |f|
		f << generateVerilogRunner(moduleName, verilogRunnerName, moduleParamNames, moduleParamDecls, modulePortNames, modulePortDecls, rubyRunnerPath, $specFormat)
	end
	puts "generated #{verilogRunnerPath}"

	File.open(rubyRunnerPath, "w") do |f|
		f << generateRubyRunner($specFormat, modulePortNames, specClassName, rubySpecPath)
	end
	puts "generated #{rubyRunnerPath}"

	File.open(rubyDesignPath, "w") do |f|
		f << generateRubyDesign(designClassName, modulePortNames, verilogRunnerName)
	end
	puts "generated #{rubyDesignPath}"

	File.open(rubySpecPath, "w") do |f|
		f << generateRubySpec($specFormat, designClassName, specClassName, rubyDesignPath, modulePortNames)
	end
	puts "generated #{rubySpecPath}"
end
