# Concurrent processes.
#--
# Copyright 2007 Suraj N. Kurapati
# See the file named LICENSE for details.

Thread.abort_on_exception = true

module RubyVPI::Scheduler #:nodoc:
end

module RubyVPI
  module Scheduler
    @@time = 0
    Callback.relay_verilog(VPI::CbReadOnlySynch, 0) unless RubyVPI::USE_PROTOTYPE

    def Scheduler.current_time
      @@time
    end


    @@thread2state = { Thread.main => :run }
    @@thread2state_lock = Mutex.new

    @@scheduler = Thread.new do
      # pause because boot loader is not fully init yet
      Thread.stop

      loop do
        # finish software execution in current time step
          loop do
            ready = @@thread2state_lock.synchronize do
              Thread.exit if @@thread2state.empty?

              @@thread2state.all? do |(thread, state)|
                thread.stop? and state == :wait
              end
            end

            if ready
              break
            else
              Thread.pass
            end
          end

          Edge.refresh_cache
          Callback.relay_verilog(VPI::CbAfterDelay, 1) unless RubyVPI::USE_PROTOTYPE
          Scheduler.flush_writes

        # run hardware in next time step
          @@time += 1

          if RubyVPI::USE_PROTOTYPE
            Prototype.simulate_hardware
            Scheduler.flush_writes
          else
            Callback.relay_verilog(VPI::CbReadOnlySynch, 0)
          end

        # resume software execution in new time step
          @@thread2state_lock.synchronize do
            @@thread2state.keys.each do |thr|
              @@thread2state[thr] = :run
              thr.wakeup
            end
          end
      end
    end

    def Scheduler.start
      @@scheduler.wakeup if @@scheduler.alive?
    end

    def Scheduler.stop
      @@scheduler.exit
    end

    def Scheduler.ensure_caller_is_registered
      isRegistered =
        @@thread2state_lock.synchronize do
          @@thread2state.key? Thread.current
        end

      unless isRegistered
        raise SecurityError, 'This method may only be invoked from within a process (see the Vpi::process method).'
      end
    end


    # Registers the calling thread with the scheduler.
    def Scheduler.attach
      @@thread2state_lock.synchronize do
        @@thread2state[Thread.current] = :run
      end
    end

    # Unregisters the calling thread from the scheduler.
    def Scheduler.detach
      @@thread2state_lock.synchronize do
        @@thread2state.delete Thread.current
      end
    end

    # Waits for the scheduler to arrive in the next time step.
    def Scheduler.await
      @@thread2state_lock.synchronize do
        @@thread2state[Thread.current] = :wait
      end

      Thread.stop
    end


    #-------------------------------------------------------------------------
    # buffer/cache all writes
    #-------------------------------------------------------------------------

    @@handle2write = Hash.new {|h,k| h[k] = []}
    @@handle2write_lock = Mutex.new

    def Scheduler.capture_write aHandle, *aArgs
      @@handle2write_lock.synchronize do
        @@handle2write[aHandle] << aArgs
      end
    end

    def Scheduler.flush_writes
      @@handle2write_lock.synchronize do
        @@handle2write.each_pair do |handle, writes|
          writes.each do |args|
            VPI.__scheduler__vpi_put_value(handle, *args)
          end

          writes.clear
        end
      end
    end


    # Finalizes the simulation for the boot loader.
    def Scheduler.exit_ruby
      raise unless Thread.current == Thread.main
      Scheduler.ensure_caller_is_registered

      # now that the main thread is finished, let the
      # thread scheduler take over the entire Ruby process
      Scheduler.detach
      Scheduler.start
      raise unless @@scheduler.join

      # return control to the simulator before Ruby exits.
      # otherwise, the simulator will not have a chance to do
      # any clean up or finish any pending tasks that remain
      VPI.__extension__relay_verilog unless $!
    end
  end
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

  # Stop the simulation and exit the program.
  def finish
    RubyVPI::Scheduler.ensure_caller_is_registered
    RubyVPI::Scheduler.stop
  end


  # Creates a new concurrent thread, which will execute the
  # given block with the given arguments, and returns it.
  def process *aBlockArgs
    RubyVPI::Scheduler.ensure_caller_is_registered
    raise ArgumentError, "block must be given" unless block_given?

    Thread.new do
      RubyVPI::Scheduler.attach
      yield(*aBlockArgs)
      RubyVPI::Scheduler.detach
    end
  end

  # Wraps the given block inside an infinite loop and executes it
  # inside a new concurrent thread (see the VPI::process method).
  def always *aBlockArgs, &aBlock
    process do
      loop do
        aBlock.call(*aBlockArgs)
      end
    end
  end

  alias forever always
end
