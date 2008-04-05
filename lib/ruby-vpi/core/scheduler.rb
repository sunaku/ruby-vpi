# Concurrent processes.
#--
# Copyright 2007 Suraj N. Kurapati
# See the file named LICENSE for details.

Thread.abort_on_exception = true

require 'singleton'

module RubyVPI
  class SchedulerClass #:nodoc:
    include Singleton


    Task = Struct.new(:thread, :state)

    class Task #:nodoc:
      def run
        self.state = :run
        self.thread.wakeup
      end

      def stop
        self.state = :wait
        Thread.stop
      end

      def stop?
        self.thread.stop? and self.state == :wait
      end
    end


    def initialize
      @thread2task = { Thread.current => Task.new(Thread.current, :run) }
      @thread2task_soft = @thread2task.dup  # software threads
      @thread2task_hard = {} # hardware threads (Ruby prototype of DUT)
      @thread2task_lock = Mutex.new

      # base case: hardware runs first before any software does at startup
        @time = 0

        unless RubyVPI::USE_PROTOTYPE
          Callback.relay_verilog(VPI::CbReadOnlySynch, 0)
        end

      @scheduler = Thread.new do
        # pause because boot loader is not fully initialized yet
        Thread.stop

        loop do
          # run software in current time step
            run_tasks @thread2task_soft, true
            Edge.refresh_cache

            # go to time slot where writing is permitted before flushing writes
            unless RubyVPI::USE_PROTOTYPE
              Callback.relay_verilog(VPI::CbAfterDelay, 1)
            end

            flush_writes

          # run hardware in next time step
            @time += 1

            if RubyVPI::USE_PROTOTYPE
              run_tasks @thread2task_hard, false
              flush_writes
            else
              Callback.relay_verilog(VPI::CbReadOnlySynch, 0)
            end
        end
      end


      @handle2write = Hash.new {|h,k| h[k] = []}
      @handle2write_lock = Mutex.new
    end

    def current_time
      @time
    end

    def start
      @scheduler.wakeup
    end

    # Registers the calling thread with the scheduler.
    def attach
      key = Thread.current

      hash =
        if caller.grep(/_proto\.rb/).empty?
          @thread2task_soft
        else
          @thread2task_hard
        end

      @thread2task_lock.synchronize do
        task = Task.new(key, :run)
        hash[key] = task
        @thread2task[key] = task
      end
    end

    # Unregisters the calling thread from the scheduler.
    def detach
      key = Thread.current

      @thread2task_lock.synchronize do
        @thread2task.delete key
        @thread2task_hard.delete key
        @thread2task_soft.delete key
      end
    end

    # Waits for the scheduler to arrive in the next time step.
    def await
      key = Thread.current

      task = @thread2task_lock.synchronize do
        @thread2task[key]
      end

      task.stop
    end

    def ensure_caller_is_registered
      unless @thread2task_lock.synchronize {@thread2task.key? Thread.current}
        raise SecurityError, 'This method may only be invoked from within a process (see the VPI::process() method).'
      end
    end

    Write = Struct.new :thread, :trace, :args

    # Captures the given write operation so it
    # can be flushed later, at the correct time.
    def capture_write aHandle, *aArgs
      @handle2write_lock.synchronize do
        @handle2write[aHandle] << Write.new(Thread.current, caller, aArgs)
      end
    end

    private

    # Flushes all captured writes.
    def flush_writes
      @handle2write_lock.synchronize do
        @handle2write.each_pair do |handle, writes|
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

    def run_tasks aHash, aExitWhenEmpty
      @thread2task_lock.synchronize do
        tasks = aHash.values
        tasks.each {|t| t.run}

        if aExitWhenEmpty && tasks.empty?
          Thread.exit
        end
      end

      until @thread2task_lock.synchronize { aHash.values.all? {|t| t.stop? } }
        Thread.pass
      end
    end
  end

  Scheduler = SchedulerClass.instance
end

module VPI
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
    RubyVPI::Scheduler.ensure_caller_is_registered
    aNumTimeSteps.times { RubyVPI::Scheduler.await }
  end

  alias wait advance_time


  # Creates a new concurrent process, which will execute the
  # given block with the given arguments, and returns it.
  def process *aBlockArgs
    RubyVPI::Scheduler.ensure_caller_is_registered
    raise ArgumentError, 'block must be given' unless block_given?

    Thread.new do
      RubyVPI::Scheduler.attach
      yield(*aBlockArgs)
      RubyVPI::Scheduler.detach
    end
  end

  # Wraps the given block inside an infinite loop and executes it
  # inside a new concurrent process (see the VPI::process method).
  def always *aBlockArgs, &aBlock
    process do
      loop do
        startTime = VPI.current_time
        aBlock.call(*aBlockArgs)
        finishTime = VPI.current_time

        VPI.advance_time unless finishTime > startTime
      end
    end
  end

  alias forever always
end
