# A library for parsing Verilog source code.
#--
# Copyright 2006-2007 Suraj N. Kurapati
# See the file named LICENSE for details.

require 'ruby-vpi/util'

class VerilogParser
  attr_reader :modules

  # Parses the given Verilog source code.
  def initialize aInput
    input = aInput.dup

    # strip comments
      input.gsub! %r{//.*$}, ''
      input.gsub! %r{/\*.*?\*/}m, ''

    @modules = input.scan(%r{(module.*?;)(.*?)endmodule}m).map do |matches|
      Module.new(*matches)
    end
  end

  class Module
    attr_reader :decl, :body, :name,
                :ports, :input_ports, :output_ports,
                :clock_port, :reset_port

    def initialize aDecl, aBody
      @decl = aDecl.strip
      @body = aBody

      @decl =~ %r{module\s+(\w+)\s*(?:\#\(.*?\))?\s*\((.*?)\)\s*;}m
      @name, portDecls = $1, $2

      @ports        = portDecls.split(',').map {|decl| Port.new decl, self}
      @input_ports  = @ports.select {|p| p.input?}
      @output_ports = @ports.select {|p| p.output?}

      @clock_port   = @ports.find {|p| p.name =~ /clock|clo?c?k/i}
      @reset_port   = @ports.find {|p| p.name =~ /reset|re?se?t/i}
    end

    class Port
      attr_reader :decl, :name

      def initialize aDecl, aModule
        @decl = aDecl
        @name = aDecl.scan(/\S+/).last

        parser = /\b(input|output|inout)\b[^;]*\b#{@name}\b/m
        aDecl =~ parser || aModule.body =~ parser
        @type = $1
      end

      def input?
        @type != 'output'
      end

      def output?
        @type != 'input'
      end
    end
  end
end

class String
  # Converts this string containing Verilog
  # code into syntactically correct Ruby code.
  def verilog_to_ruby
    content = self.dup

    # single-line comments
      content.gsub! %r{//(.*)$}, '#\1'

    # multi-line comments
      content.gsub! %r{/\*.*?\*/}m, "\n=begin\n\\0\n=end\n"

    # preprocessor directives
      content.gsub! %r{`include}, '#\0'

      content.gsub! %r{`define\s+(\w+)\s+(.+)} do
        "#{$1.to_ruby_const_name} = #{$2}"
      end

      content.gsub! %r{`+}, ''

    # numbers
      content.gsub! %r{\d*\'([dohb]\w+)}, '0\1'

    # ranges
      content.gsub! %r{(\S)\s*:\s*(\S)}, '\1..\2'

    content
  end
end
