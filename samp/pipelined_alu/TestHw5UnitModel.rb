require 'int_gen'
require 'Hw5UnitModel'
require 'test/unit'

class TestHw5UnitModel < Test::Unit::TestCase
  NUM_VECTORS = 4000

  def setup
    @model = Hw5UnitModel.new
    @ingen = IntegerGenerator.new 32
  end

  def test_reset
    @model.reset
    assert_same Hw5UnitModel::NOP, @model.output
  end

  def testModel
    # generate input for module
    inputQueue = []

    NUM_VECTORS.times do |i|
      inputQueue << Hw5UnitModel::Operation.new(
        Hw5UnitModel::OPERATIONS[rand(Hw5UnitModel::OPERATIONS.size)],
        i,
        @ingen.random.abs,
        @ingen.random.abs
      )
    end


    # test the module
    outputQueue = []
    cycle = 0

    until inputQueue.length == outputQueue.length
      if $DEBUG
        print "\n" * 3
        p ">> cycle #{cycle}"
      end


      # start a new operation
      if cycle < inputQueue.length
        @model.startOperation inputQueue[cycle]
        cycle += 1
      end


      # simulate a clock cycle
      @model.cycle


      # verify the output
      output = @model.output
      p "output:", output if $DEBUG

      unless output == Hw5UnitModel::NOP
        assert_not_nil inputQueue.find {|op| op.tag == output.tag }, "unknown tag on result: #{output.tag}"
        assert_equal output.compute, output.result, "incorrect result"

        outputQueue << output
      end


      if $DEBUG
        puts
        pp @model
      end
    end
  end
end
