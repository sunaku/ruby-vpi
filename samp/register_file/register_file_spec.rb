require 'spec'

module RegisterInterface
  NUM_REGS = Register_file.register.size

  def set_registers(vals)
    raise ArgumentError if vals.length > NUM_REGS

    Register_file.rw.force_value 1

    vals.each_with_index do |val, i|
      Register_file.wtReg.intVal = i
      Register_file.inBus.intVal = val
      Register_file.cycle!
    end

    Register_file.rw.release_value
  end

  def expect_registers(vals)
    raise ArgumentError if vals.length > NUM_REGS

    Register_file.rw.force_value 0

    vals.each_with_index do |val, i|
      Register_file.rdReg.intVal = i
      Register_file.cycle!
      Register_file.outBus.intVal.should == val
    end

    Register_file.rw.release_value
  end
end

describe "An enabled register file" do
  include RegisterInterface

  before do
    Register_file.reset!
    Register_file.enable.force_value 1
  end

  after do
    Register_file.enable.release_value
  end

  it "should be able to write and then read registers" do
    testVals = [1, 7, 3, 12]

    set_registers(testVals)
    expect_registers(testVals)
  end
end

describe "A disabled register file" do
  include RegisterInterface

  before do
    Register_file.reset!
    Register_file.enable.force_value 0
  end

  after do
    Register_file.enable.release_value
  end

  it "should not write new values" do
    zeros    = [0, 0, 0, 0]
    testVals = [1, 7, 3, 12]

    set_registers(testVals)
    expect_registers(zeros)
  end
end
