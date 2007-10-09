require 'spec'

module RegisterInterface
  NUM_REGS = DUT.register.size

  def set_registers(vals)
    raise ArgumentError if vals.length > NUM_REGS

    DUT.rw.intVal = 1

    vals.each_with_index do |val, i|
      DUT.wtReg.intVal = i
      DUT.inBus.intVal = val
      DUT.cycle!
    end
  end

  def expect_registers(vals)
    raise ArgumentError if vals.length > NUM_REGS

    DUT.rw.intVal = 0

    vals.each_with_index do |val, i|
      DUT.rdReg.intVal = i
      DUT.cycle!
      DUT.outBus.intVal.should == val
    end
  end
end

describe "A #{DUT.name}, when enabled" do
  include RegisterInterface

  before do
    DUT.reset!
    DUT.enable.intVal = 1
  end

  it "should be able to write and then read registers" do
    testVals = [1, 7, 3, 12]

    set_registers(testVals)
    expect_registers(testVals)
  end
end

describe "A #{DUT.name}, when disabled" do
  include RegisterInterface

  before do
    DUT.reset!
    DUT.enable.intVal = 0
  end

  it "should not write new values" do
    zeros    = [0, 0, 0, 0]
    testVals = [1, 7, 3, 12]

    set_registers(testVals)
    expect_registers(zeros)
  end
end
