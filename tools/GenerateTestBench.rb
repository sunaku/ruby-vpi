# Generates a Ruby-VPI test bench (including a Verilog portion and a Ruby portion) for a given Verilog module.

=begin
	Copyright 2006 Suraj Kurapati

  This file is part of Ruby-VPI.

	Ruby-VPI is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

	Ruby-VPI is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
=end


# sanitize the input
input = ARGF.read

	# strip single-line comments
	input.gsub! %r{//.*$}, ""

	# collapse the input into a single line
	input.tr! ?\n.chr, ' '

	# strip multi-line comments
	input.gsub! %r{/\*.*\*/}, ""


# parse the input
moduleDecl = input.scan(%r{module.*?;}).first

moduleName = moduleDecl.scan(%r{module\s+(\w+)\s*\(}).first.first

moduleParamDecl = moduleDecl.gsub(%r{module.*?\((.*)\)\s*;\s*$}, %q{\1})
moduleParamDecl.gsub! %r{(\W)reg(\W)}, %q{\1\2}	# make all parameters unregistered

moduleParamNames = []
moduleParamDecl.scan(%r{(\w+)\s*[,\)]}) {|name| moduleParamNames << name.first}


# determine output destinations
destModuleName = "#{moduleName}_tb"
verilogDest = destModuleName + ".v"
rubyDest = destModuleName + ".rb"


# generate verilog test bench
File.open(verilogDest, "w") do |f|
	# accessors for inputs & outputs
	accessorDecl = moduleParamDecl.dup

	{ "input" => "reg", "output" => "wire" }.each_pair do |key, val|
		accessorDecl.gsub! %r{(\W#{key}\s+)(.*?)[,\)]}, "#{val} \\2;"
	end


	# instantiation for the module under test
	instParamDecl = moduleParamNames.inject([]) {|arr, param| arr << ".#{param}(#{param})"}.join(",")
	instDecl = "#{moduleName} dut (#{instParamDecl});"


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
					end.join(?\n.chr)
				}
			end
		end
	};

	puts "generated #{rubyDest}"
end
