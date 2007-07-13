require 'spec'

module RegisterInterface
  MAX_INDEX = Register_file.register.size - 1

  def set_registers(vals)
    Register_file.rw.intVal = 1

    0.upto(MAX_INDEX) do |i|
      Register_file.wtReg.intVal = i
      Register_file.inBus.intVal = vals[i]
      Register_file.cycle!
    end
  end

  def expect_registers(vals)
    Register_file.rw.intVal = 0

    MAX_INDEX.downto(0) do |i|
      Register_file.rdReg.intVal = i
      Register_file.cycle!
      Register_file.outBus.intVal.should == vals[i]
    end
  end
end

describe "An enabled register file" do
  include RegisterInterface

  before do
    Register_file.reset!
    Register_file.enable.intVal = 1
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
    Register_file.enable.intVal = 0
  end

  it "should not write new values" do
    zeros    = [0, 0, 0, 0]
    testVals = [1, 7, 3, 12]

    set_registers(testVals)
    expect_registers(zeros)
  end
end
