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

require 'InputGenerator'
require 'Hw5UnitModel'
require 'test/unit'
require 'pp'

class TestHw5UnitModel < Test::Unit::TestCase
  NUM_VECTORS = 4000

  def setup
    @model = Hw5UnitModel.new
    @ingen = InputGenerator.new 32
  end

  def test_reset
    @model.reset
    assert_same Hw5UnitModel::NOP, @model.output
  end

  def testModel
    # generate input for module
    inputQueue = []

    NUM_VECTORS.times do |i|
      inputQueue << Hw5UnitModel::Operation.new(Hw5UnitModel::OPERATIONS[rand(Hw5UnitModel::OPERATIONS.size)], i, @ingen.gen.abs, @ingen.gen.abs)
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
