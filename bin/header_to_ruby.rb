#!/usr/bin/ruby -w
# Transforms Verilog header files into Ruby.
# * If no input files are specified, then the standard input stream is assumed to be the input.
# * The resulting output is emitted to the standard output stream.

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

if File.basename($0) == File.basename(__FILE__)
  # parse command-line options
    require 'optparse'

    opts = OptionParser.new
    opts.banner = "Usage: #{File.basename __FILE__} [options] [files]"

    opts.on '-h', '--help', 'show this help message' do
      require 'ruby-vpi/rdoc'
      RDoc.usage_from_file __FILE__

      puts opts
      exit
    end

    opts.parse! ARGV

  require 'ruby-vpi/verilog_parser'
  puts ARGF.read.verilog_to_ruby
end
