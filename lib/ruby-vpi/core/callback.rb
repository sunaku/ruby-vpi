# Simulation callbacks.
#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

require 'singleton'

module RubyVPI
  class CallbackClass #:nodoc:
    include Singleton

    def initialize
      @id2handler = {}
      @id2receipt = {}
      @lock = Mutex.new
    end

    def attach aData, &aHandler
      raise ArgumentError, "block must be given" unless block_given?
      id = aHandler.object_id.to_s

      # register the callback with Verilog
      aData.user_data = id
      aData.cb_rtn    = VPI::Vlog_relay_ruby
      receipt         = VPI.__callback__vpi_register_cb(aData)

      @lock.synchronize do
        @id2handler[id] = aHandler
        @id2receipt[id] = receipt
      end

      receipt
    end

    def detach aData
      id = aData.user_data.to_s
      receipt = @lock.synchronize{ @id2receipt[id] }

      if receipt
        VPI.__callback__vpi_remove_cb(receipt)

        @lock.synchronize do
          @id2handler.delete id
          @id2receipt.delete id
        end
      end
    end

    # Transfers control to the simulator, which will return control
    # during the given time slot after the given number of time steps.
    def relay_verilog aTimeSlot, aNumSteps
      # schedule wake-up callback from verilog
        time            = VPI::S_vpi_time.new
        time.integer    = aNumSteps
        time.type       = VPI::VpiSimTime

        value           = VPI::S_vpi_value.new
        value.format    = VPI::VpiSuppressVal

        alarm           = VPI::S_cb_data.new
        alarm.reason    = aTimeSlot
        alarm.cb_rtn    = VPI::RubyVPI_host_resume
        alarm.obj       = nil
        alarm.time      = time
        alarm.value     = value
        alarm.index     = 0
        alarm.user_data = nil

        VPI.vpi_free_object(VPI.__callback__vpi_register_cb(alarm))

      # transfer control to verilog
        # while ring = RubyVPI.pause
        #   # id = ring.user_data.to_s
        #   # handler = @lock.synchronize { @id2handler[id] }

        #   # if handler
        #   #   handler.call ring
        #   # else
        #     break
        #   # end
        # end

        RubyVPI.pause
    end
  end

  Callback = CallbackClass.instance
end

module VPI
  class Handle
    # Registers a callback that is invoked
    # whenever the value of this object changes.
    def cbValueChange aOptions = {}, &aHandler
      raise ArgumentError unless block_given?

      aOptions[:time]  ||= S_vpi_time.new(:type => VpiSuppressTime)
      aOptions[:value] ||= S_vpi_value.new(:format => VpiSuppressVal)

      alarm = S_cb_data.new(
        :reason => CbValueChange,
        :obj    => self,
        :time   => aOptions[:time],
        :value  => aOptions[:value],
        :index  => 0
      )

      vpi_register_cb alarm, &aHandler
    end
  end


  alias_method :__callback__vpi_register_cb, :vpi_register_cb
  module_function :__callback__vpi_register_cb

  # This is a Ruby version of the vpi_register_cb C function.  It is
  # identical to the C function, except for the following differences:
  #
  # * This method accepts a block (callback handler)
  #   which is executed whenever the callback occurs.
  #
  # * This method overwrites the +cb_rtn+ and +user_data+
  #   fields of the given +S_cb_data+ object.
  #
  def vpi_register_cb aData, &aHandler # :yields: VPI::S_cb_data
    raise ArgumentError, "block must be given" unless block_given?
    RubyVPI::Callback.attach(aData, &aHandler)
  end


  alias_method :__callback__vpi_remove_cb, :vpi_remove_cb
  module_function :__callback__vpi_remove_cb

  def vpi_remove_cb aData # :nodoc:
    RubyVPI::Callback.detach(aData)
  end
end
