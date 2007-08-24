# A utility layer which transforms the VPI interface
# into one that is more suitable for Ruby.
#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

module VPI
  # restore compatibility with the C language version of VPI: in Ruby,
  # constants are capitalized, whereas in C, they do not have to be.
  constants.grep(/^(S_|Cb|Vpi)/).each do |name|
    meth  = name[0,1].downcase << name[1..-1]
    value = const_get(name)

    define_method meth do value end
    module_function meth
  end

  # Number of bits in PLI_INT32.
  INTEGER_BITS  = 32

  # Lowest upper bound of PLI_INT32.
  INTEGER_LIMIT = 2 ** INTEGER_BITS

  # Bit-mask capable of capturing PLI_INT32.
  INTEGER_MASK  = INTEGER_LIMIT - 1
end

module RubyVPI
  USE_DEBUGGER  = ENV['DEBUGGER'].to_i  == 1
  USE_COVERAGE  = ENV['COVERAGE'].to_i  == 1
  USE_PROTOTYPE = ENV['PROTOTYPE'].to_i == 1
  USE_SIMULATOR = ENV['RUBYVPI_SIMULATOR'].to_sym
end

require 'thread'
require 'ruby-vpi/core/struct'
require 'ruby-vpi/core/handle'
require 'ruby-vpi/core/edge'
require 'ruby-vpi/core/callback'
require 'ruby-vpi/core/scheduler'
