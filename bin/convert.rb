# Transforms Verilog header files into Ruby.
# * The standard input stream is read if no input files are specified.
# * Output is written to the standard output stream.

#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

$: << File.join(File.dirname(__FILE__), '..', 'lib')

# parse command-line options
  require 'optparse'

  opts = OptionParser.new
  opts.banner = "Usage: ruby-vpi convert [options] [files]"

  opts.on '-h', '--help', 'show this help message' do
    require 'ruby-vpi/rdoc'
    RDoc.usage_from_file __FILE__

    puts opts
    exit
  end

  opts.parse! ARGV

require 'ruby-vpi/verilog_parser'
puts ARGF.read.verilog_to_ruby
