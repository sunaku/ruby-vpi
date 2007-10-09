# General project information.
#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

module RubyVPI
  PROJECT_ID      = 'ruby-vpi'
  PROJECT_NAME    = 'Ruby-VPI'
  PROJECT_URL     = "http://#{PROJECT_ID}.rubyforge.org"
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

  # Speaks the given message using printf().
  def RubyVPI.say fmt, *args #:nodoc:
    VPI.vpi_printf("#{PROJECT_NAME}: #{fmt}\n", *args)
  end

  # Loads a test that exercises a design (the given VPI handle).
  #
  # 1. Creates a sandbox (an anonymous module).
  #
  # 2. Defines a constant named "DUT" (which points
  #    to the given VPI handle) inside the sandbox.
  #
  # 3. Loads the given test files into the sandbox.
  #
  # 4. Returns the sandbox.
  #
  # aDesignHandleOrPath:: either a VPI handle or a path to an
  #                       object in the Verilog simulation
  #
  def RubyVPI.load_test aDesignHandleOrPath, *aTestFilePaths
    design =
      if aDesignHandleOrPath.is_a? VPI::Handle
        aDesignHandleOrPath
      else
        VPI.vpi_handle_by_name(aDesignHandleOrPath.to_s, nil)
      end

    raise ArgumentError, "cannot access the design under test: #{aDesignHandleOrPath.inspect}" unless design


    sandbox = Module.new
    sandbox.const_set :DUT, design

    aTestFilePaths.flatten.compact.uniq.each do |path|
      sandbox.module_eval(File.read(path), path)
    end

    sandbox
  end
end
