#!/usr/bin/env ruby
# == Synopsis
# Generates a Ruby-VPI test bench (composed of a Verilog file and a Ruby file) from Verilog 2001 module declarations.
#
# == Usage
# ruby generate_test.rb [option...] [input-file...]
#
# option::
# 	A command-line option, such as "--help".
#
# input-file::
# 	A source file which contains one or more Verilog 2001 module declarations.
#
# If no input files are specified, then the standard input stream will be read instead.

=begin
	Copyright 2006 Suraj Kurapati

  This file is part of Ruby-VPI.

	Ruby-VPI is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

	Ruby-VPI is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
=end

require 'optparse'
require 'rdoc/usage'

DEST_SUFFIX = '_tb'


# parse command-line options
opts = OptionParser.new
opts.on('-h', '--help') {RDoc::usage}
opts.parse(ARGV) rescue RDoc::usage('usage')


# sanitize the input
input = ARGF.read

	# strip single-line comments
	input.gsub! %r{//.*$}, ""

	# collapse the input into a single line
	input.tr! "\n", ' '

	# strip multi-line comments
	input.gsub! %r{/\*.*?\*/}, ""


# parse the input
input.scan(%r{module.*?;}).each do |moduleDecl|
	moduleName = moduleDecl.scan(%r{module\s+(\w+)\s*\(}).first.first

	moduleParamDecl = moduleDecl.gsub(%r{module.*?\((.*)\)\s*;}, '\1')
	moduleParamDecl.gsub! %r{\breg\b}, ""	# make all parameters unregistered

	moduleParamDecls = moduleParamDecl.split(/,/)

	moduleParamNames = moduleParamDecls.inject([]) do |acc, decl|
		acc << decl.scan(%r{\w+}).last
	end

	puts "parsed #{moduleName}"


	# determine output destinations
	destModuleName = moduleName + DEST_SUFFIX
	verilogDest = destModuleName + ".v"
	rubyDest = destModuleName + ".rb"


	# generate verilog test bench
	File.open(verilogDest, "w") do |f|

		# accessors for inputs & outputs of DUT
		accessorDecl = moduleParamDecls.inject("") do |acc, decl|
			{ "input" => "reg", "output" => "wire" }.each_pair do |key, val|
				decl.gsub! %r{\b#{key}\b(.*?)$}, "#{val}\\1;"
			end

			acc << decl
		end


		# instantiation for the DUT
		instParamDecl = moduleParamNames.inject([]) {|acc, param| acc << ".#{param}(#{param})"}.join(', ')
		instDecl = "#{moduleName} #{destModuleName}_dut (#{instParamDecl});"


		f << %{
			module #{destModuleName};

				/* accessors for the DUT */
				#{accessorDecl}


				/* instantiate the DUT */
				#{instDecl}


				/* interface to Ruby-VPI */
				initial begin
					#0 $ruby_init("-w", "#{rubyDest}");
					#1 clk = 0; reset = 0;
				end

				/* generate a 50% duty-cycle clock for the DUT */
				always begin
					#5 clk = ~clk;
				end

				/* transfer control to Ruby-VPI every clock cycle */
				always @(posedge clk) begin
					$ruby_relay();
				end

			endmodule
		}

		puts "generated #{verilogDest}"
	end


	# generate Ruby test bench
	File.open(rubyDest, "w") do |f|
		f << %{
			require 'test/unit'

			class #{destModuleName.capitalize} < Test::Unit::TestCase
				include Vpi

				def setup
					#{
						moduleParamNames.inject([]) do |acc, param|
							acc << %{@#{param} = vpi_handle_by_name("#{destModuleName}.#{param}", nil)}
						end.join("\n")
					}
				end
			end
		}

		puts "generated #{rubyDest}"
	end
end
