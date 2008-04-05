# Interface to VPI handles.
#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

require 'ruby-vpi/util'

module VPI
  Handle = SWIG::TYPE_p_unsigned_int

  # A handle is an object inside a Verilog simulation (see
  # *vpiHandle* in IEEE Std.  1364-2005 for details).
  #
  # Nearly all methods of this class, such as put_value()
  # and get_value(), you allow you to specify VPI types
  # and properties (which are listed in ext/vpi_user.h) by
  # their names (strings or symbols) or integer constants.
  #
  # For example, the vpiIntVal property can be specified as a string
  # (<code>"vpiIntVal"</code>), a symbol (<code>:vpiIntVal</code>), or as
  # an integer (<code>VpiIntVal</code> or <code>VPI::vpiIntVal</code>).
  #
  class Handle
    include VPI

    #---------------------------------------------------------------------------
    # testing & setting common logic values
    #---------------------------------------------------------------------------

    # Tests if the integer value of this handle is 1.
    def vpi1?
      get_value(VpiScalarVal) == Vpi1
    end

    # Sets the integer value of this handle to 1.
    def vpi1!
      put_value(Vpi1, VpiScalarVal)
    end

    alias t? vpi1?
    alias t! vpi1!


    # Tests if the integer value of this handle is 0.
    def vpi0?
      get_value(VpiScalarVal) == Vpi0
    end

    # Sets the integer value of this handle to 0.
    def vpi0!
      put_value(Vpi0, VpiScalarVal)
    end

    alias f? vpi0?
    alias f! vpi0!


    # Tests if the logic value of this handle is unknown (x).
    def vpiX?
      get_value(VpiScalarVal) == VpiX
    end

    # Sets the logic value of this handle to unknown (x).
    def vpiX!
      put_value(VpiX, VpiScalarVal)
    end

    alias x? vpiX?
    alias x! vpiX!


    # Tests if the logic value of this handle is high impedance (z).
    def vpiZ?
      get_value(VpiScalarVal) == VpiZ
    end

    # Sets the logic value of this handle to high impedance (z).
    def vpiZ!
      put_value(VpiZ, VpiScalarVal)
    end

    alias z? vpiZ?
    alias z! vpiZ!


    # Tests if the strength value of this handle is high.
    def vpiH?
      get_value(VpiScalarVal) == VpiH
    end

    # Sets the strength value of this handle to high.
    def vpiH!
      put_value(VpiH, VpiScalarVal)
    end

    alias h? vpiH?
    alias h! vpiH!


    # Tests if the strength value of this handle is low.
    def vpiL?
      get_value(VpiScalarVal) == VpiL
    end

    # Sets the strength value of this handle to low.
    def vpiL!
      put_value(VpiL, VpiScalarVal)
    end

    alias l? vpiL?
    alias l! vpiL!


    # Inspects the given VPI property names, in
    # addition to those common to all handles.
    def inspect *aPropNames
      aPropNames.unshift :name, :fullName, :size, :file, :lineNo, :hexStrVal

      aPropNames.map! do |name|
        "#{name}=#{__send__(name).inspect}"
      end

      "#<VPI::Handle #{vpi_get_str(VpiType, self)} #{aPropNames.join(', ')}>"
    end

    alias to_s inspect


    #---------------------------------------------------------------------------
    # reading & writing values
    #---------------------------------------------------------------------------

    # Reads the value using the given format (name or
    # integer constant) and returns a +S_vpi_value+ object.
    def get_value_wrapper aFormat
      fmt = resolve_prop_type(aFormat)
      val = S_vpi_value.new(:format => fmt)
      vpi_get_value(self, val)
      val
    end

    # Reads the value using the given format (name or integer constant) and
    # returns it.  If a format is not given, then it is assumed to be VpiIntVal.
    def get_value aFormat = VpiIntVal
      fmt = resolve_prop_type(aFormat)
      @size ||= vpi_get(VpiSize, self)

      if fmt == VpiIntVal and @size > INTEGER_BITS
        fmt = VpiBinStrVal
        val = get_value_wrapper(fmt)
        val.read(fmt).gsub(/[^01]/, '0').to_i(2)
      else
        val = get_value_wrapper(fmt)
        val.read(fmt)
      end
    end

    # Writes the given value using the given format (name or integer
    # constant), time, and delay, and then returns the written value.
    #
    # * If you do not specify the format, then the Verilog
    #   simulator will attempt to determine the correct format.
    #
    def put_value aValue, aFormat = nil, aTime = nil, aDelay = VpiNoDelay
      if vpi_get(VpiType, self) == VpiNet
        aDelay = VpiForceFlag

        if driver = self.to_a(VpiDriver).find {|d| vpi_get(VpiType, d) != VpiForce}
          warn "forcing value #{aValue.inspect} onto wire #{self} that is already driven by #{driver.inspect}"
        end
      end

      aFormat =
        if aFormat
          resolve_prop_type(aFormat)
        else
          S_vpi_value.detect_format(aValue) ||
          get_value_wrapper(VpiObjTypeVal).format # let the simulator detect
        end

      if aFormat == VpiIntVal
        @size ||= vpi_get(VpiSize, self)

        unless @size < INTEGER_BITS
          aFormat = VpiHexStrVal
          aValue  = aValue.to_i.to_s(16)
        end
      end

      aTime ||= S_vpi_time.new(:type => VpiSimTime, :integer => 0)

      wrapper = S_vpi_value.new(:format => aFormat)
      result  = wrapper.write(aValue, aFormat)

      vpi_put_value(self, wrapper, aTime, aDelay)

      result
    end

    # Forces the given value (see arguments for #put_value) onto this handle.
    def force_value *args
      args[3] = VpiForceFlag
      put_value(*args)
    end

    # Releases all forced values on this handle (if any).
    def release_value
      # this doesn't really change the value, it only removes the force flag
      put_value(0, VpiIntVal, nil, VpiReleaseFlag)
    end

    # Tests if there is currently a value forced onto this handle.
    def force?
      self.to_a(VpiDriver).any? {|d| vpi_get(VpiType, d) == VpiForce}
    end


    #---------------------------------------------------------------------------
    # accessing related handles / traversing the hierarchy
    #---------------------------------------------------------------------------

    # Returns the child handle at the given relative VPI path.
    def / aRelativePath
      access_child(aRelativePath)
    end

    # Returns an array of child handles which have
    # the given types (names or integer constants).
    def to_a *aChildTypes
      handles = []

      aChildTypes.each do |arg|
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
      list = Enumerable.instance_methods

      if RubyVPI::HAVE_RUBY_19X
        list.delete :to_a
        list.push :each
      else
        list.delete 'to_a'
        list.push 'each'
      end

      list.each do |meth|
        # using a string because define_method
        # does not accept a block until Ruby 1.9
        class_eval %{
          def #{meth}(*args, &block)
            if ary = self.to_a(*args)
              ary.#{meth}(&block)
            end
          end

          # these methods should NOT interfere with
          # method_missing access to child handles
          private :#{meth}
        }, __FILE__, __LINE__
      end

    # Sort by absolute VPI path.
    def <=> other
      get_value(VpiFullName) <=> other.get_value(VpiFullName)
    end


    #---------------------------------------------------------------------------
    # accessing VPI properties
    #---------------------------------------------------------------------------

    # Returns the value of the given VPI property
    # (name or integer constant) of this handle.
    def [] aProp
      access_prop(aProp)
    end

    @@propCache = Hash.new {|h,k| h[k] = Property.new(k)}

    undef id if respond_to? :id # deprecated in Ruby 1.8; removed in Ruby 1.9
    undef type if respond_to? :type # used to access VpiType; also same as above

    # Provides access to this handle's (1) child handles and (2) VPI
    # properties through method calls.  In the case that a child handle
    # has the same name as a VPI property, the child handle will be
    # accessed instead of the VPI property.  However, you can still
    # access the VPI property using the square brackets #[] method.
    def method_missing aMeth, *aArgs, &aBlock
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
            access_prop(#{aMeth.inspect}, *a, &b)
          end
        }, __FILE__, __LINE__

        __send__(aMeth, *aArgs, &aBlock)
      end
    end

    private

    def access_child aPath
      vpi_handle_by_name(aPath.to_s, self)
    end

    def access_prop aProp, *aArgs, &aBlock
      @@propCache[aProp.to_sym].execute(self, *aArgs, &aBlock)
    end

    class Property # :nodoc:
      attr_reader :name, :type, :accessor, :operation

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
            @type = VPI.const_get(@name)
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
          when :d # delay values
            raise NotImplementedError, 'processing of delay values is not yet implemented.'
            # TODO: vpi_put_delays
            # TODO: vpi_get_delays

          when :l # logic values
            if @isAssign
              value = aArgs.shift
              aHandle.put_value(value, @type, *aArgs)
            else
              aHandle.get_value(@type)
            end

          when :i # integer values
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
              value && (value != 0) # zero is false in C
            end

          when :s # string values
            if @isAssign
              raise NotImplementedError
            else
              vpi_get_str(@type, aHandle)
            end

          when :h # handle values
            if @isAssign
              raise NotImplementedError
            else
              vpi_handle(@type, aHandle)
            end

          when :a # array of child handles
            if @isAssign
              raise NotImplementedError
            else
              aHandle.to_a(@type)
            end

          else
            raise NoMethodError, "cannot access VPI property #{@name.inspect} for handle #{aHandle.inspect} through method #{@methName.inspect} with arguments #{aArgs.inspect}"
          end
        end
      end
    end

    # resolve type names into type constants
    def resolve_prop_type aNameOrType
      if aNameOrType.respond_to? :to_int and not aNameOrType.is_a? Symbol
        aNameOrType.to_int
      else
        @@propCache[aNameOrType.to_sym].type
      end
    end
  end
end
