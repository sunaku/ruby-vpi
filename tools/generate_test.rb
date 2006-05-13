#!/usr/bin/env ruby
#
# == Synopsis
# Generates a Ruby-VPI test bench (composed of a Verilog file and a Ruby file) from Verilog 2001 module declarations.
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
require 'ostruct'

DEST_SUFFIX = '_tb'


# Fixes the left indentation of the given output by the indentation of its first line, and then returns it.
def fixIndent! aOutput
	aOutput =~ %r{\n+([\t ]+)}

	if indentation = $1
		aOutput.gsub! %r{(\n+)#{indentation}}, '\1'
	end

	aOutput
end


# parse command-line options
OPTS = OpenStruct.new
OPTS.rSpec = OPTS.rUnit = false

optsParser = OptionParser.new
optsParser.on('-h', '--help', 'show this help message') {raise}
optsParser.on('-u', '--rUnit', 'generate Test::Unit friendly output') {|v| OPTS.rUnit = v}
optsParser.on('-s', '--rSpec', 'generate RSpec friendly output') {|v| OPTS.rSpec = v}

begin
	optsParser.parse!(ARGV)
rescue
	puts optsParser
	RDoc::usage
end


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
	moduleName, moduleConfigDecl, moduleParamDecl = $1, $3 || '', $4


	# parse configuration parameters
	moduleConfigDecl.gsub! %r{\bparameter\b}, ''
	moduleConfigDecl.strip!

	moduleConfigDecls = moduleConfigDecl.split(/,/)

	moduleConfigNames = moduleConfigDecls.inject([]) do |acc, decl|
		acc << decl.scan(%r{\w+}).first
	end


	# parse signal parameters
	moduleParamDecl.gsub! %r{\breg\b}, ''
	moduleParamDecl.strip!

	moduleParamDecls = moduleParamDecl.split(/,/)

	moduleParamNames = moduleParamDecls.inject([]) do |acc, decl|
		acc << decl.scan(%r{\w+}).last
	end


	puts "parsed #{moduleName}"



	# determine output destinations
	destModuleName = moduleName + DEST_SUFFIX
	verilogDest = destModuleName + ".v"
	rubyDest = destModuleName + ".rb"


	# generate Verilog test bench
	File.open(verilogDest, "w") do |f|

		# configuration parameters for DUT
		configDecl = moduleConfigDecls.inject('') do |acc, decl|
			acc << "parameter #{decl};\n"
		end


		# accessors for DUT interface
		accessorInitDecl = moduleParamDecls.inject('') do |acc, decl|
			{ 'input' => 'reg', 'output' => 'wire' }.each_pair do |key, val|
				decl.sub! %r{\b#{key}\b(.*?)$}, "#{val}\\1;"
			end

			decl.strip!
			acc << decl << "\n"
		end


		# instantiation for the DUT

			# creates a comma-separated string of parameter declarations in module instantiation format
			def makeInstParamDecl(paramNames)
				paramNames.inject([]) {|acc, param| acc << ".#{param}(#{param})"}.join(', ')
			end

		instConfigDecl = makeInstParamDecl(moduleConfigNames)
		instParamDecl = makeInstParamDecl(moduleParamNames)

		instDecl = "#{moduleName} " << (
			unless instConfigDecl.empty?
				"\#(#{instConfigDecl})"
			else
				''
			end
		) << " #{destModuleName}_dut (#{instParamDecl});"


		clockSignal = moduleParamNames.first

		f << fixIndent!(%{
			module #{destModuleName};

				/* configuration for the DUT */
				#{configDecl}

				/* accessors for the DUT */
				#{accessorInitDecl}

				/* instantiate the DUT */
				#{instDecl}


				/* interface to Ruby-VPI */
				initial begin
					#{clockSignal} = 0;
					$ruby_init("-w", "#{rubyDest}");
				end

				/* generate a 50% duty-cycle clock for the DUT */
				always begin
					#5 #{clockSignal} = ~#{clockSignal};
				end

				/* transfer control to Ruby-VPI every clock cycle */
				always @(posedge #{clockSignal}) begin
					$ruby_relay();
				end

			endmodule
		})

		puts "generated #{verilogDest}"
	end


	# generate Ruby test bench
	File.open(rubyDest, "w") do |f|

		# accessors for DUT interface
		accessorDecl = moduleParamNames.inject([]) do |acc, param|
			acc << ":#{param}"
		end.join(', ')

		accessorInitDecl = moduleParamNames.inject('') do |acc, param|
			acc << %{@#{param} = Vpi::vpi_handle_by_name("#{destModuleName}.#{param}", nil)\n}
		end


		# tests for DUT accessors
		accessorTestDecl = moduleParamNames.inject('') do |acc, param|
			acc << "def test_#{param}\nend\n\n"
		end

		className = moduleName.capitalize
		testClassName = destModuleName.capitalize


		f << fixIndent!(%{
			require 'vpi_util'
			#{
				case
					when OPTS.rUnit
						"require 'test/unit'"

					when OPTS.rSpec
						"require 'rspec'"
				end
			}

			\# interface to the design
			class #{className}
				attr_reader #{accessorDecl}

				def initialize
					#{accessorInitDecl}
				end
			end

			\# verify the design
			#{
				case
					when OPTS.rUnit
						%{
							class #{testClassName} < Test::Unit::TestCase
								include Vpi

								def setup
									@design = #{className}.new
								end

								#{accessorTestDecl}
							end
						}

					when OPTS.rSpec
						%{
							context "A new #{className}" do
								setup do
									@design = #{className}.new
								end

								specify "should ..." do
									# @design.should ...
								end
							end
						}

					else
						%{
							class #{testClassName}
								include Vpi

								def initialize
									@design = #{className}.new
								end
							end
						}
				end
			}

			\# bootstrap this file
			if $0 == __FILE__
				\# $ruby_init():
				Vpi::relay_verilog

				\# $ruby_relay():
				#{
					case
						when OPTS.rUnit
							'# RUnit will take control from here.'

						when OPTS.rSpec
							'# RSpec will take control from here.'

						else
							testClassName + '.new'
					end
				}
			end
		})

		puts "generated #{rubyDest}"
	end
end
