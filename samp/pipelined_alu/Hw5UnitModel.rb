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

# Behavioral model of the hw5_unit Verilog module.
class Hw5UnitModel

  # Represents an ALU operation.
  class Operation
    attr_accessor :type, :tag, :arg1, :arg2, :stage, :result

    def initialize(type, tag, arg1 = 0, arg2 = 0)
      raise ArgumentError unless OPERATIONS.include? type

      @type = type
      @tag = tag
      @arg1 = arg1
      @arg2 = arg2

      @stage = 0
    end

    # Computes the result of this operation.
    def compute
      case @type
        when :add
          @arg1 + @arg2

        when :sub
          @arg1 - @arg2

        when :mul
          @arg1 * @arg2

        when :nop
          nil

        else
          raise
      end
    end

    def compute!
      @result = compute
    end
  end


  # Supported types of ALU operations.
  OPERATIONS = [ :add, :sub, :mul, :nop ]

  # Number of cycles each operation uses.
  OPERATION_LATENCIES = {
    :add => 1,
    :sub => 2,
    :mul => 3,
    :nop => 1,
  }

  # The famous no-operation.
  NOP = Hw5UnitModel::Operation.new(:nop, nil)


  def reset
    @aluQueues = {}
    @outputQueue = []

    # create a separate pipeline for each operation
    OPERATIONS.each do |op|
      @aluQueues[op] = []
    end
  end

  alias_method :initialize, :reset


  # Starts the given operation during the present cycle.
  def startOperation(op)
    @aluQueues[op.type] << op

    p "started operation:", op  if $DEBUG
  end

  # Performs the behavior for the present cycle.
  def cycle
    # perform ALU operations
    @aluQueues.each_pair do |alu, pipeline|
      finished = []

      pipeline.each do |op|
        # when the operation has finished all pipeline stages, compute the result and output it
        if op.stage >= OPERATION_LATENCIES[op.type]
          op.compute!
          finished << op
          @outputQueue << op
        end


        # perform the next stage of the operation
        op.stage += 1
      end


      # remove finished operations from pipeline
      @aluQueues[alu] = pipeline - finished
    end
  end

  # Returns the output for the present cycle.
  def output
    unless @outputQueue.empty?
      @outputQueue.shift
    else
      NOP
    end
  end

end
