# Value change / edge detection for handles.
#--
# Copyright 2007 Suraj N. Kurapati
# See the file named LICENSE for details.

require 'singleton'

module RubyVPI
  class EdgeClass #:nodoc:
    include Singleton

    def initialize
      @handles = []
      @lock = Mutex.new
    end

    # Begins monitoring the given handle for value change.
    def monitor aHandle
      # ignore handles that cannot hold a meaningful value
      type = VPI::vpi_get_str(VpiType, aHandle)
      return if type =~ /Bit|Array|Module|Parameter/

      @lock.synchronize do
        unless @handles.include? aHandle
          @handles << aHandle
          refresh_handle aHandle
        end
      end
    end

    # Refreshes the cached value of all monitored handles.
    def refresh_cache
      @lock.synchronize do
        @handles.each do |h|
          refresh_handle h
        end
      end
    end

    # Remember the current value as the "previous" value.
    def refresh_handle aHandle
      aHandle.instance_eval do
        @__edge__prev_val = get_value(VpiHexStrVal)
      end
    end
  end

  Edge = EdgeClass.instance
end

module VPI
  class Handle
    # create methods for detecting all possible value changes
    vals  = %w[0 1 x z]
    edges = vals.map {|a| vals.map {|b| a + b}}.flatten

    edges.each do |edge|
      meth = "change_#{edge}?"
      old, new = edge.split(//)

      old_int  = old =~ /[01]/
      new_int  = new =~ /[01]/

      old_read = old_int ? 'int' : 'hex'
      new_read = new_int ? 'VpiIntVal' : 'VpiHexStrVal'

      old_test = old_int ? "== #{old}" : "=~ /#{old}/i"
      new_test = new_int ? "== #{new}" : "=~ /#{new}/i"

      class_eval %{
        def #{meth}
          old = __edge__prev_val_#{old_read}
          new = get_value(#{new_read})

          old #{old_test} and new #{new_test}
        end
      }
    end

    alias posedge? change_01?
    alias negedge? change_10?

    # Tests if either a positive or negative edge has occurred.
    def edge?
      posedge? or negedge?
    end

    # Tests if the logic value of this handle has
    # changed since the last simulation time step.
    def change?
      old = __edge__prev_val_hex
      new = get_value(VpiHexStrVal)

      old != new
    end


    private

    # Returns the previous value as a hex string.
    def __edge__prev_val_hex #:nodoc:
      @__edge__prev_val.to_s
    end

    # Returns the previous value as an integer.
    def __edge__prev_val_int #:nodoc:
      __edge__prev_val_hex.to_i(16)
    end
  end

  %w[
    vpi_handle_by_name
    vpi_handle_by_index
    vpi_handle
    vpi_scan
  ].each do |src|
    dst = "__value_change__#{src}"
    alias_method dst, src

    define_method src do |*args|
      if result = __send__(dst, *args)
        RubyVPI::Edge.monitor(result)
      end

      result
    end
  end
end
