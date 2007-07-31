# A utility layer which transforms the VPI interface
# into one that is more suitable for Ruby.
#--
# Copyright 2006-2007 Suraj N. Kurapati
# See the file named LICENSE for details.

require 'ruby-vpi/util'

module Vpi
  # Number of bits in PLI_INT32.
  INTEGER_BITS  = 32

  # Lowest upper bound of PLI_INT32.
  INTEGER_LIMIT = 2 ** INTEGER_BITS

  # Bit-mask capable of capturing PLI_INT32.
  INTEGER_MASK  = INTEGER_LIMIT - 1

  # handles

    Handle = SWIG::TYPE_p_unsigned_int

    # A handle is an object inside a Verilog simulation (see
    # *vpiHandle* in IEEE Std.  1364-2005).  VPI types and
    # properties listed in ext/vpi_user.h can be specified by
    # their names (strings or symbols) or integer constants.
    #
    # = Example names
    # * "intVal"
    # * :intVal
    # * "vpiIntVal"
    # * :vpiIntVal
    # * "VpiIntVal"
    # * :VpiIntVal
    #
    # = Example constants
    # * VpiIntVal
    # * VpiModule
    # * VpiReg
    #
    class Handle
      include Vpi

      # Tests if the logic value of this handle is unknown (x).
      def x?
        self.hexStrVal =~ /x/i
      end

      # Sets the logic value of this handle to unknown (x).
      def x!
        self.hexStrVal = 'x'
      end

      # Tests if the logic value of this handle is high impedance (z).
      def z?
        self.hexStrVal =~ /z/i
      end

      # Sets the logic value of this handle to high impedance (z).
      def z!
        self.hexStrVal = 'z'
      end

      # Tests if the logic value of this handle is at "logic high" level.
      def high?
        self.intVal != 0
      end

      # Sets the logic value of this handle to "logic high" level.
      def high!
        self.intVal = 1
      end

      # Tests if the logic value of this handle is at "logic low" level.
      def low?
        self.hexStrVal =~ /^0+$/
      end

      # Sets the logic value of this handle to "logic low" level.
      def low!
        self.intVal = 0
      end

      # Tests if the logic value of this handle is currently at a positive edge.
      def posedge?
        old = @lastVal
        new = @lastVal = self.intVal

        old == 0 && new == 1
      end

      # Tests if the logic value of this handle is currently at a negative edge.
      def negedge?
        old = @lastVal
        new = @lastVal = self.intVal

        old == 1 && new == 0
      end

      # Reads the value using the given
      # format (integer constant) and
      # returns a +S_vpi_value+ object.
      def get_value_wrapper aFormat
        val        = S_vpi_value.new
        val.format = aFormat

        vpi_get_value self, val
        val
      end

      # Reads the value using the given format (name or
      # integer constant) and returns it.  If a format is
      # not given, then it is assumed to be VpiIntVal.
      def get_value aFormat = VpiIntVal
        val = get_value_wrapper(resolve_prop_type(aFormat))

        case val.format
          when VpiBinStrVal, VpiOctStrVal, VpiDecStrVal, VpiHexStrVal, VpiStringVal
            val.value.str

          when VpiScalarVal
            val.value.scalar

          when VpiIntVal
            @size ||= vpi_get(VpiSize, self)

            if @size < 32
              val.value.integer
            else
              val = get_value_wrapper(VpiBinStrVal)
              val.value.str.to_s.gsub(/[^01]/, '0').to_i(2)
            end

          when VpiRealVal
            val.value.real

          when VpiTimeVal
            val.value.time

          when VpiVectorVal
            val.value.vector

          when VpiStrengthVal
            val.value.strength

          else
            raise "unknown S_vpi_value.format: #{val.format}"
        end
      end

      # Writes the given value using the given format (name or integer
      # constant), time, and delay, and then returns the written value.
      #
      # * If a format is not given, then the Verilog simulator
      #   will attempt to determine the correct format.
      #
      # * If the given format is VpiIntVal, then the given value
      #   will be truncated to fit the VpiSize of this handle.
      #
      def put_value aValue, aFormat = nil, aTime = nil, aDelay = VpiNoDelay
        aFormat = if aFormat
          resolve_prop_type(aFormat)

        elsif aValue.respond_to? :to_int
          VpiIntVal

        elsif aValue.respond_to? :to_float
          VpiRealVal

        elsif aValue.respond_to? :to_str
          VpiStringVal

        elsif aValue.is_a? S_vpi_time
          VpiTimeVal

        elsif aValue.is_a? S_vpi_vecval
          VpiVectorVal

        elsif aValue.is_a? S_vpi_strengthval
          VpiStrengthVal

        else
          get_value_wrapper(VpiObjTypeVal).format
        end

        newVal = S_vpi_value.new(:format => aFormat)

        writtenVal = case aFormat
          when VpiBinStrVal, VpiOctStrVal, VpiDecStrVal, VpiHexStrVal, VpiStringVal
            newVal.value.str      = aValue.to_s

          when VpiScalarVal
            newVal.value.scalar   = aValue.to_i

          when VpiIntVal
            @size ||= vpi_get(VpiSize, self)

            if @size < 32
              newVal.format        = VpiIntVal
              newVal.value.integer = aValue.to_i
            else
              newVal.format        = VpiHexStrVal
              newVal.value.str     = aValue.to_i.to_s(16)
            end

          when VpiRealVal
            newVal.value.real     = aValue.to_f

          when VpiTimeVal
            newVal.value.time     = aValue

          when VpiVectorVal
            newVal.value.vector   = aValue

          when VpiStrengthVal
            newVal.value.strength = aValue

          else
            raise "unknown S_vpi_value.format: #{newVal.format.inspect}"
        end

        vpi_put_value(self, newVal, aTime, aDelay)

        writtenVal
      end

      # Returns an array of child handles of the
      # given types (name or integer constant).
      def [] *aTypes
        handles = []

        aTypes.each do |arg|
          t = resolve_prop_type(arg)

          if itr = vpi_iterate(t, self)
            while h = vpi_scan(itr)
              handles << h
            end
          end
        end

        handles
      end


        # inherit Enumerable methods, such as #each, #map, #select, etc.
        Enumerable.instance_methods.push('each').each do |meth|
          # using a string because define_method
          # does not accept a block until Ruby 1.9
          class_eval %{
            def #{meth}(*args, &block)
              if ary = self[*args]
                ary.#{meth}(&block)
              end
            end
          }, __FILE__, __LINE__
        end

        # bypass Enumerable's #to_a method, which relies on #each
        alias to_a []

        # Sort by absolute VPI path.
        def <=> other
          self.fullName <=> other.fullName
        end


      # Inspects the given VPI property names, in
      # addition to those common to all handles.
      def inspect *aPropNames
        aPropNames.unshift :name, :fullName, :size, :file, :lineNo

        aPropNames.map! do |name|
          "#{name}=#{self.send(name.to_sym)}"
        end

        "#<Vpi::Handle #{vpiType_s} #{aPropNames.join(', ')}>"
      end

      alias to_s inspect

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


      @@propCache = Hash.new {|h, k| h[k] = Property.new(k)}

      # Provides access to this handle's (1) child handles
      # and (2) VPI properties through method calls.  In the
      # case that a child handle has the same name as a VPI
      # property, the child handle will be accessed instead
      # of the VPI property.  However, you can still access
      # the VPI property via #get_value and #put_value.
      def method_missing aMeth, *aArgs, &aBlockArg
        # cache the result for future accesses, in order
        # to cut down number of calls to method_missing()
        eigen_class = (class << self; self; end)

        if child = vpi_handle_by_name(aMeth.to_s, self)
          eigen_class.class_eval do
            define_method aMeth do
              child
            end
          end

          child
        else
          # XXX: using a string because define_method() does
          #      not support a block argument until Ruby 1.9
          eigen_class.class_eval %{
            def #{aMeth}(*a, &b)
              @@propCache[#{aMeth.inspect}].execute(self, *a, &b)
            end
          }

          self.__send__(aMeth, *aArgs, &aBlockArg)
        end
      end

      private

      class Property # :nodoc:
        def initialize aMethName
          @methName = aMethName.to_s

          # parse property information from the given method name
            tokens = @methName.split('_')

            tokens.last.sub!(/[\?!=]$/, '')
            addendum  = $&
            @isAssign = $& == '='
            isQuery   = $& == '?'

            tokens.last =~ /^[a-z]$/ && tokens.pop
            @accessor = $&

            @name = tokens.pop

            @operation = unless tokens.empty?
              tokens.join('_') << (addendum || '')
            end

          # determine the VPI integer type for the property
            @name = @name.to_ruby_const_name
            @name.insert 0, 'Vpi' unless @name =~ /^[Vv]pi/

            begin
              @type = Vpi.const_get(@name)
            rescue NameError
              raise ArgumentError, "#{@name.inspect} is not a valid VPI property"
            end

          @accessor = if @accessor
            @accessor.to_sym
          else
            # infer accessor from VPI property @name
            if isQuery
              :b
            else
              case @name
                when /Time$/
                  :d

                when /Val$/
                  :l

                when /Type$/, /Direction$/, /Index$/, /Size$/, /Strength\d?$/, /Polarity$/, /Edge$/, /Offset$/, /Mode$/, /LineNo$/
                  :i

                when /Is[A-Z]/, /ed$/
                  :b

                when /Name$/, /File$/, /Decompile$/
                  :s

                when /Parent$/, /Inst$/, /Range$/, /Driver$/, /Net$/, /Load$/, /Conn$/, /Bit$/, /Word$/, /[LR]hs$/, /(In|Out)$/, /Term$/, /Argument$/, /Condition$/, /Use$/, /Operand$/, /Stmt$/, /Expr$/, /Scope$/, /Memory$/, /Delay$/
                  :h
              end
            end
          end
        end

        def execute aHandle, *aArgs, &aBlockArg
          if @operation
            aHandle.__send__(@operation, @type, *aArgs, &aBlockArg)
          else
            case @accessor
              when :d	# delay values
                raise NotImplementedError, 'processing of delay values is not yet implemented.'
                # TODO: vpi_put_delays
                # TODO: vpi_get_delays

              when :l	# logic values
                if @isAssign
                  value = aArgs.shift
                  aHandle.put_value(value, @type, *aArgs)
                else
                  aHandle.get_value(@type)
                end

              when :i	# integer values
                if @isAssign
                  raise NotImplementedError
                else
                  vpi_get(@type, aHandle)
                end

              when :b # boolean values
                if @isAssign
                  raise NotImplementedError
                else
                  value = vpi_get(@type, aHandle)
                  value && (value != 0)	# zero is false in C
                end

              when :s	# string values
                if @isAssign
                  raise NotImplementedError
                else
                  vpi_get_str(@type, aHandle)
                end

              when :h	# handle values
                if @isAssign
                  raise NotImplementedError
                else
                  vpi_handle(@type, aHandle)
                end

              when :a # array of child handles
                if @isAssign
                  raise NotImplementedError
                else
                  aHandle[@type]
                end

              else
                raise NoMethodError, "cannot access VPI property #{@name.inspect} for handle #{aHandle.inspect} through method #{@methName.inspect} with arguments #{aArgs.inspect}"
            end
          end
        end
      end

      # resolve type names into type constants
      def resolve_prop_type aNameOrType
        if aNameOrType.respond_to? :to_int
          aNameOrType.to_int
        else
          @@propCache[aNameOrType.to_sym].type
        end
      end
    end


  # callbacks

    Callback = Struct.new :handler, :token #:nodoc:
    @@callbacks = {}

    alias vpi_register_cb_old vpi_register_cb

    # This is a Ruby version of the vpi_register_cb C function.  It is
    # identical to the C function, except for the following differences:
    #
    # * This method accepts a block (callback handler)
    #   which is executed whenever the callback occurs.
    #
    # * This method overwrites the +cb_rtn+ and +user_data+
    #   fields of the given +S_cb_data+ object.
    #
    def vpi_register_cb aData, &aHandler # :yields: Vpi::S_cb_data
      raise ArgumentError, "block must be given" unless block_given?

      key = aHandler.object_id.to_s

      # register the callback with Verilog
        aData.user_data = key
        aData.cb_rtn    = Vlog_relay_ruby
        token           = vpi_register_cb_old(aData)

      @@callbacks[key]  = Callback.new(aHandler, token)
      token
    end

    alias vpi_remove_cb_old vpi_remove_cb

    def vpi_remove_cb aData # :nodoc:
      key = aData.user_data

      if c = @@callbacks[key]
        vpi_remove_cb_old c.token
        @@callbacks.delete key
      end
    end

    # Proxy for relay_verilog which supports callbacks.  This method
    # should NOT be invoked from callback handlers (see vpi_register_cb)
    # and threads -- otherwise the situation will be like seven remote
    # controls changing the channel on a single television set!
    def relay_verilog_proxy # :nodoc:
      loop do
        relay_verilog

        if reason = relay_ruby_reason # might be nil
          dst = reason.user_data

          if c = @@callbacks[dst]
            c.handler.call reason
          else
            break # main thread is receiver
          end
        end
      end
    end


  # simulation control

    # Advances the simulation by the given number of steps.
    def advance_time aNumSteps = 1
      # schedule wake-up callback from verilog
        time            = S_vpi_time.new
        time.integer    = aNumSteps
        time.type       = VpiSimTime

        value           = S_vpi_value.new
        value.format    = VpiSuppressVal

        alarm           = S_cb_data.new
        alarm.reason    = CbReadWriteSynch
        alarm.cb_rtn    = Vlog_relay_ruby
        alarm.obj       = nil
        alarm.time      = time
        alarm.value     = value
        alarm.index     = 0
        alarm.user_data = nil

        vpi_free_object(vpi_register_cb_old(alarm))

      # relay to verilog
        relay_verilog_proxy
    end


  # utility

    # Returns the current simulation time as an integer.
    def simulation_time
      t = S_vpi_time.new :type => VpiSimTime
      vpi_get_time nil, t
      t.to_i
    end

    class S_vpi_time
      # Returns the high and low portions of
      # this time as a single 64-bit integer.
      def integer
        (self.high << INTEGER_BITS) | self.low
      end

      # Sets the high and low portions of this
      # time from the given 64-bit integer.
      def integer= aValue
        self.low  = aValue & INTEGER_MASK
        self.high = (aValue >> INTEGER_BITS) & INTEGER_MASK
      end

      alias to_i integer
      alias to_f real
    end

    class S_vpi_value
      def to_i
        value.integer
      end

      def to_f
        value.real
      end

      def to_s
        value.str
      end
    end

    # make VPI structs more accessible by allowing their
    # members to be initialized through the constructor
    constants.grep(/^S_/).each do |s|
      const_get(s).class_eval do
        alias old_initialize initialize

        def initialize aMembers = {} #:nodoc:
          old_initialize

          aMembers.each_pair do |k, v|
            __send__ "#{k}=", v
          end
        end
      end
    end
end
