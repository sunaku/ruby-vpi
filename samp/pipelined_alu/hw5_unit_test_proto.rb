# This is a prototype of the design under test.
class << Hw5_unit
  # When prototyping is enabled, this method is invoked
  # instead of Vpi::relay_verilog to simulate the design.
  def simulate!
    raise NotImplementedError, "Prototype is not yet implemented."

    # discard old outputs
      res.hexStrVal = 'x'
      out_databits.hexStrVal = 'x'
      out_op.hexStrVal = 'x'

    # process new inputs

    # produce new outputs
  end
end
