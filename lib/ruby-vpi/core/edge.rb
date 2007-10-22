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
        @__edge__prev_val = get_value(VpiScalarVal)
      end
    end
  end

  Edge = EdgeClass.instance
end

module VPI
  class Handle

# XXX: this code generates code for the following methods.  I
#      could just class_eval() the generated code, but then
#      the method names and descriptions will not show up in
#      the API docs.  So just for the sake of documentation,
#      I am pasting the generated code into this file.
=begin
    # create methods for detecting all possible value changes
    vals  = %w[1 0 X Z H L]
    edges = vals.map {|a| vals.map {|b| a + b}}.flatten

    edges.each do |edge|
      meth = "change_#{edge.downcase}?"
      old, new = edge.split(//).map {|s| 'Vpi' + s}

      # class_eval %{
      puts %{
        # Tests if the logic value of this handle has changed from #{old}
        # (in the previous time step) to #{new} (in the current time step).
        def #{meth}
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == #{old} && new == #{new}
        end
      }
    end
=end

#-------------------------------------------------------------------------------
# begin generated code
#-------------------------------------------------------------------------------


        # Tests if the logic value of this handle has changed from Vpi1
        # (in the previous time step) to Vpi1 (in the current time step).
        def change_11?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == Vpi1 && new == Vpi1
        end


        # Tests if the logic value of this handle has changed from Vpi1
        # (in the previous time step) to Vpi0 (in the current time step).
        def change_10?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == Vpi1 && new == Vpi0
        end


        # Tests if the logic value of this handle has changed from Vpi1
        # (in the previous time step) to VpiX (in the current time step).
        def change_1x?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == Vpi1 && new == VpiX
        end


        # Tests if the logic value of this handle has changed from Vpi1
        # (in the previous time step) to VpiZ (in the current time step).
        def change_1z?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == Vpi1 && new == VpiZ
        end


        # Tests if the logic value of this handle has changed from Vpi1
        # (in the previous time step) to VpiH (in the current time step).
        def change_1h?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == Vpi1 && new == VpiH
        end


        # Tests if the logic value of this handle has changed from Vpi1
        # (in the previous time step) to VpiL (in the current time step).
        def change_1l?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == Vpi1 && new == VpiL
        end


        # Tests if the logic value of this handle has changed from Vpi0
        # (in the previous time step) to Vpi1 (in the current time step).
        def change_01?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == Vpi0 && new == Vpi1
        end


        # Tests if the logic value of this handle has changed from Vpi0
        # (in the previous time step) to Vpi0 (in the current time step).
        def change_00?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == Vpi0 && new == Vpi0
        end


        # Tests if the logic value of this handle has changed from Vpi0
        # (in the previous time step) to VpiX (in the current time step).
        def change_0x?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == Vpi0 && new == VpiX
        end


        # Tests if the logic value of this handle has changed from Vpi0
        # (in the previous time step) to VpiZ (in the current time step).
        def change_0z?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == Vpi0 && new == VpiZ
        end


        # Tests if the logic value of this handle has changed from Vpi0
        # (in the previous time step) to VpiH (in the current time step).
        def change_0h?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == Vpi0 && new == VpiH
        end


        # Tests if the logic value of this handle has changed from Vpi0
        # (in the previous time step) to VpiL (in the current time step).
        def change_0l?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == Vpi0 && new == VpiL
        end


        # Tests if the logic value of this handle has changed from VpiX
        # (in the previous time step) to Vpi1 (in the current time step).
        def change_x1?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiX && new == Vpi1
        end


        # Tests if the logic value of this handle has changed from VpiX
        # (in the previous time step) to Vpi0 (in the current time step).
        def change_x0?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiX && new == Vpi0
        end


        # Tests if the logic value of this handle has changed from VpiX
        # (in the previous time step) to VpiX (in the current time step).
        def change_xx?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiX && new == VpiX
        end


        # Tests if the logic value of this handle has changed from VpiX
        # (in the previous time step) to VpiZ (in the current time step).
        def change_xz?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiX && new == VpiZ
        end


        # Tests if the logic value of this handle has changed from VpiX
        # (in the previous time step) to VpiH (in the current time step).
        def change_xh?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiX && new == VpiH
        end


        # Tests if the logic value of this handle has changed from VpiX
        # (in the previous time step) to VpiL (in the current time step).
        def change_xl?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiX && new == VpiL
        end


        # Tests if the logic value of this handle has changed from VpiZ
        # (in the previous time step) to Vpi1 (in the current time step).
        def change_z1?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiZ && new == Vpi1
        end


        # Tests if the logic value of this handle has changed from VpiZ
        # (in the previous time step) to Vpi0 (in the current time step).
        def change_z0?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiZ && new == Vpi0
        end


        # Tests if the logic value of this handle has changed from VpiZ
        # (in the previous time step) to VpiX (in the current time step).
        def change_zx?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiZ && new == VpiX
        end


        # Tests if the logic value of this handle has changed from VpiZ
        # (in the previous time step) to VpiZ (in the current time step).
        def change_zz?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiZ && new == VpiZ
        end


        # Tests if the logic value of this handle has changed from VpiZ
        # (in the previous time step) to VpiH (in the current time step).
        def change_zh?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiZ && new == VpiH
        end


        # Tests if the logic value of this handle has changed from VpiZ
        # (in the previous time step) to VpiL (in the current time step).
        def change_zl?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiZ && new == VpiL
        end


        # Tests if the logic value of this handle has changed from VpiH
        # (in the previous time step) to Vpi1 (in the current time step).
        def change_h1?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiH && new == Vpi1
        end


        # Tests if the logic value of this handle has changed from VpiH
        # (in the previous time step) to Vpi0 (in the current time step).
        def change_h0?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiH && new == Vpi0
        end


        # Tests if the logic value of this handle has changed from VpiH
        # (in the previous time step) to VpiX (in the current time step).
        def change_hx?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiH && new == VpiX
        end


        # Tests if the logic value of this handle has changed from VpiH
        # (in the previous time step) to VpiZ (in the current time step).
        def change_hz?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiH && new == VpiZ
        end


        # Tests if the logic value of this handle has changed from VpiH
        # (in the previous time step) to VpiH (in the current time step).
        def change_hh?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiH && new == VpiH
        end


        # Tests if the logic value of this handle has changed from VpiH
        # (in the previous time step) to VpiL (in the current time step).
        def change_hl?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiH && new == VpiL
        end


        # Tests if the logic value of this handle has changed from VpiL
        # (in the previous time step) to Vpi1 (in the current time step).
        def change_l1?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiL && new == Vpi1
        end


        # Tests if the logic value of this handle has changed from VpiL
        # (in the previous time step) to Vpi0 (in the current time step).
        def change_l0?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiL && new == Vpi0
        end


        # Tests if the logic value of this handle has changed from VpiL
        # (in the previous time step) to VpiX (in the current time step).
        def change_lx?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiL && new == VpiX
        end


        # Tests if the logic value of this handle has changed from VpiL
        # (in the previous time step) to VpiZ (in the current time step).
        def change_lz?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiL && new == VpiZ
        end


        # Tests if the logic value of this handle has changed from VpiL
        # (in the previous time step) to VpiH (in the current time step).
        def change_lh?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiL && new == VpiH
        end


        # Tests if the logic value of this handle has changed from VpiL
        # (in the previous time step) to VpiL (in the current time step).
        def change_ll?
          old = @__edge__prev_val
          new = get_value(VpiScalarVal)

          old == VpiL && new == VpiL
        end

#-------------------------------------------------------------------------------
# end generated code
#-------------------------------------------------------------------------------


    alias posedge? change_01?
    alias negedge? change_10?

    # Tests if either a positive or negative edge has occurred.
    def edge?
      posedge? or negedge?
    end

    # Tests if the logic value of this handle has
    # changed since the last simulation time step.
    def change?
      old = @__edge__prev_val
      new = get_value(VpiScalarVal)

      old != new
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
