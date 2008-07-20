# Concurrent processes (coroutines).
#--
# Copyright 2007 Suraj N. Kurapati
# See the file named LICENSE for details.

Thread.abort_on_exception = true

require 'singleton'
require 'generator'

module RubyVPI
  class SchedulerClass #:nodoc:
    include Singleton

    def initialize
      @writes = Hash.new {|h,k| h[k] = []}
      @writes_lock = Mutex.new

      # for coroutines in Ruby-based prototypes of Verilog hardware
      @routines = []
      @routines_lock = Mutex.new
      @current_routine = nil

      @current_time = 0

      # allow "initial" blocks in Verilog code of DUT to take effect
      if @current_time.zero?
        unless RubyVPI::USE_PROTOTYPE
          advance_to_read_only_slot
        end
      end
    end

    # Returns the current simulation time, as tracked by the scheduler.
    attr_reader :current_time

    # Registers a new routine with the scheduler.  The given block is the body
    # of the routine and the given arguments are passed directly to the block.
    def register_routine *aRoutineArgs, &aRoutineBody
      @routines_lock.synchronize do
        @routines << Routine.new(*aRoutineArgs, &aRoutineBody)
      end
    end

    # Makes the current routine wait for the
    # scheduler to arrive in the next time step.
    def pause_current_routine
      @current_routine.pause
    end

    # Runs the scheduler until there are no more routines to be scheduled.
    def run &aRoutineBody
      main = Routine.new(&aRoutineBody)

      until main.done?
        # run software in current time step
        resume_routine main

        Edge.refresh_cache

        # go to time slot where writing is permitted
        # before applying captured write operations
        unless RubyVPI::USE_PROTOTYPE
          if RubyVPI::USE_SIMULATOR == :vsim
            Callback.relay_verilog(VPI::CbAfterDelay, 0)
          else
            Callback.relay_verilog(VPI::CbAfterDelay, 1)
          end
        end

        apply_writes

        # run hardware in next time step
        @current_time += 1

        if RubyVPI::USE_PROTOTYPE
          @routines_lock.synchronize do
            @routines.reject! {|r| r.done? }

            @routines.each do |r|
              resume_routine r
            end
          end

          apply_writes
        else
          advance_to_read_only_slot
        end
      end
    end

    # Captures the given write operation so it
    # can be flushed later, at the correct time.
    def capture_write aHandle, *aArgs
      @writes_lock.synchronize do
        @writes[aHandle] << Write.new(Thread.current, caller, aArgs)
      end
    end

    private

    def advance_to_read_only_slot
      Callback.relay_verilog(VPI::CbReadOnlySynch, 0)
    end

    # Resumes the given routine while marking it as the current one.
    def resume_routine aRoutine
      @current_routine = aRoutine
      @current_routine.resume
      @current_routine = nil
    end

    # Represents Verilog's "process block" construct (a coroutine or concurrent
    # process), which is used as the body of an "initial" or "forever" block.
    class Routine
      def initialize *aLogicArgs, &aLogicBody
        raise ArgumentError unless block_given?

        @gen = Generator.new do |@ctl|
          pause # until we are ready to begin
          aLogicBody.call(*aLogicArgs)
        end
      end

      # Pauses the execution of this process block.
      #
      # Must be called from *inside* the logic of this process block.
      def pause
        @ctl.yield nil
      end

      # Returns true if this process block is
      # currently paused and can thus be resumed.
      #
      # Must be called from *outside* the logic of this process block.
      def pause?
        @gen.next?
      end

      # Resumes the execution of this process block.
      #
      # Must be called from *outside* the logic of this process block.
      def resume
        @gen.next
      end

      # Returns true if this process block is
      # finished (it cannot be resumed anymore).
      #
      # Must be called from *outside* the logic of this process block.
      def done?
        not pause?
      end
    end

    Write = Struct.new :thread, :trace, :args

    # Flushes all captured writes.
    def apply_writes
      @writes_lock.synchronize do
        @writes.each_pair do |handle, writes|
          if writes.map {|w| w.thread}.uniq.length > 1
            culprits = writes.map {|w| "\n\n#{w.thread}" << w.trace.map {|x| "\n\t#{x}"}.join}.join
            STDERR.puts "Race condition detected at time step #{current_time}: the logic value of handle #{handle} is being modified by more than one concurrent process: #{culprits}"
            exit 1
          end

          writes.each do |w|
            VPI.__scheduler__vpi_put_value(handle, *w.args)
          end

          writes.clear
        end
      end
    end
  end

  Scheduler = SchedulerClass.instance
end

module VPI
  # intercept all writes to VPI handles so that
  # they can be applied later by the scheduler
  alias_method :__scheduler__vpi_put_value, :vpi_put_value
  module_function :__scheduler__vpi_put_value

  def vpi_put_value *args #:nodoc:
    RubyVPI::Scheduler.capture_write(*args)
  end


  # Returns the current simulation time.
  def current_time
    RubyVPI::Scheduler.current_time
  end

  # Wait until the simulation advances by the given number of time steps.
  def advance_time aNumTimeSteps = 1
    aNumTimeSteps.times { RubyVPI::Scheduler.pause_current_routine }
  end

  alias wait advance_time


  # Creates a new concurrent process, which will execute the
  # given block with the given arguments, and returns it.
  def process *aBlockArgs, &aBlock
    RubyVPI::Scheduler.register_routine(*aBlockArgs, &aBlock)
  end

  # Wraps the given block inside an infinite loop and executes it
  # inside a new concurrent process (see the VPI::process method).
  def always *aBlockArgs, &aBlock
    process do
      loop do
        startTime = VPI.current_time
        aBlock.call(*aBlockArgs)
        finishTime = VPI.current_time

        advance_time unless finishTime > startTime
      end
    end
  end

  alias forever always
end
