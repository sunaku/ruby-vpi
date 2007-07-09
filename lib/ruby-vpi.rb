# General project information.
#--
# Copyright 2006-2007 Suraj N. Kurapati
# See the file named LICENSE for details.

module RubyVPI
  PROJECT_ID      = 'ruby-vpi'
  PROJECT_NAME    = 'Ruby-VPI'
  PROJECT_URL     = "http://#{PROJECT_ID}.rubyforge.org"
  WEBSITE_URL     = PROJECT_URL + "/doc"
  PROJECT_SUMMARY = "Ruby interface to IEEE 1364-2005 Verilog VPI"
  PROJECT_DETAIL  = "#{PROJECT_NAME} is a #{PROJECT_SUMMARY} and a platform for unit testing, rapid prototyping, and systems integration of Verilog modules through Ruby. It lets you create complex Verilog test benches easily and wholly in Ruby."

  Simulator = Struct.new(:name, :compiler_args, :linker_args)

  # List of supported Verilog simulators.
  SIMULATORS = {
    :cver   => Simulator.new('GPL Cver',        '-DPRAGMATIC_CVER',   ''),
    :ivl    => Simulator.new('Icarus Verilog',  '-DICARUS_VERILOG',   ''),
    :vcs    => Simulator.new('Synopsys VCS',    '-DSYNOPSYS_VCS',     ''),
    :vsim   => Simulator.new('Mentor Modelsim', '-DMENTOR_MODELSIM',  ''),
    :ncsim  => Simulator.new('Cadence NC-Sim',  '-DCADENCE_NCSIM',    ''),
  }

  def RubyVPI.say fmt, *args #:nodoc:
    Vpi.vpi_printf("#{PROJECT_NAME}: #{fmt}\n", *args)
  end
end
