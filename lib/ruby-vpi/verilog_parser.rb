# A library for parsing Verilog source code.
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

class VerilogParser
  attr_reader :modules, :constants

  # Parses the given Verilog source code.
  def initialize aInput
    input = aInput.dup

    # remove single-line comments
      input.gsub! %r{//.*$}, ''

    # remove multi-line comments
      input.gsub! %r{/\*.*?\*/}m, ''

    @modules = input.scan(%r{module.*?;}m).map! do |decl|
      Module.new decl
    end

    @constants = input.scan(%r{(`define\s+(\w+)\s+(.+))}).map! do |arr|
      Constant.new(*arr)
    end
  end

  Constant = Struct.new(:decl, :name, :value)

  class Module
    attr_reader :decl, :name, :parameters, :ports

    def initialize aDecl
      @decl = aDecl.strip

      @decl =~ %r{module\s+(\w+)\s*(\#\((.*?)\))?\s*\((.*?)\)\s*;}m
      @name, paramDecls, portDecls = $1, $3 || '', $4

      @parameters = paramDecls.split(/,/).map! do |decl|
        Parameter.new decl
      end

      @ports = portDecls.split(/,/).map! do |decl|
        Port.new decl
      end
    end

    class Parameter
      attr_reader :decl, :name, :value

      def initialize aDecl
        @decl = aDecl.strip

        @decl =~ %r{\bparameter\b(.*)$}
        @name, @value = $1.split(/=/).map! {|s| s.strip}
      end
    end

    class Port
      attr_reader :decl, :name, :size

      def initialize aDecl
        @decl = aDecl.strip

        @decl =~ /(\[.*?\])?\s*(\w+)$/
        @size, @name = $1, $2
      end

      def input?
        @decl =~ /\binput\b/
      end

      def output?
        @decl =~ /\boutput\b/
      end

      def reg?
        @decl =~ /\breg\b/
      end
    end
  end
end
