# General project information.
#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

module RubyVPI
  Project = {
    :name    => 'ruby-vpi',
    :version => '21.0.0',
    :release => '2008-06-08',
    :website => "http://ruby-vpi.rubyforge.org",
    :home    => File.expand_path(File.join(File.dirname(__FILE__), '..'))
  }

  Simulator = Struct.new(:id, :name, :compiler_args, :linker_args)

  # List of supported Verilog simulators.
  SIMULATORS = [
    Simulator.new(:cver,  'GPL Cver',        '-DPRAGMATIC_CVER',  ''),
    Simulator.new(:ivl,   'Icarus Verilog',  '-DICARUS_VERILOG',  ''),
    Simulator.new(:ncsim, 'Cadence NC-Sim',  '-DCADENCE_NCSIM',   ''),
    Simulator.new(:vcs,   'Synopsys VCS',    '-DSYNOPSYS_VCS',    ''),
    Simulator.new(:vsim,  'Mentor Modelsim', '-DMENTOR_MODELSIM', ''),
  ]

  # Returns the Simulator object corresponding to the given ID.
  def SIMULATORS.find_by_id aSimId
    @id2sim ||= inject({}) {|h,s| h[s.id] = s; h}
    @id2sim[aSimId]
  end

  # Speaks the given message using printf().
  def RubyVPI.say fmt, *args #:nodoc:
    VPI.vpi_printf("#{Project[:name]}: #{fmt}\n", *args)
  end

  # Loads a test to exercise a design (the given VPI handle).
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
    # access the design under test
    design =
      if aDesignHandleOrPath.is_a? VPI::Handle
        aDesignHandleOrPath
      else
        VPI.vpi_handle_by_name(aDesignHandleOrPath.to_s, nil)
      end

    raise ArgumentError, "cannot access the design under test: #{aDesignHandleOrPath.inspect}" unless design

    # create a sandbox
    sandbox = Module.new
    sandbox.const_set :DUT, design
    sandboxBinding = sandbox.module_eval('binding')

    # load files into sandbox
    aTestFilePaths.flatten.compact.uniq.each do |path|
      if HAVE_RUBY_19X
        eval File.read(path), sandboxBinding, path
      else
        sandbox.module_eval File.read(path), path
      end
    end

    sandbox
  end
end
