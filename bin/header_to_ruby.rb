#!/usr/bin/ruby -w
# Transforms Verilog header files into Ruby syntax.

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

class String
  # Converts this Verilog header content into Ruby syntax.
  def to_ruby
    content = self.dup

    # remove single-line comments
      content.gsub! %r{//(.*)$}, '#\1'

    # remove multi-line comments
      content.gsub! %r{/\*.*?\*/}m, "\n=begin\n\\0\n=end\n"

    # remove preprocessor directives
      content.gsub! %r{`include}, '#\0'
      content.gsub! %r{`define\s+(\w+)\s+(.+)}, '\1 = \2'
      content.gsub! %r{`+}, ''

    # change numbers
      content.gsub! %r{\d*\'([dohb]\w+)}, '0\1'

    # change ranges
      content.gsub! %r{(\S)\s*:\s*(\S)}, '\1..\2'

    content
  end
end

if File.basename($0) == File.basename(__FILE__)
  puts ARGF.read.to_ruby
end
