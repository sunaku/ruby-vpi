# A utility layer which transforms the VPI interface into one that is more suitable for Ruby.

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

module Vpi
  Handle = SWIG::TYPE_p_unsigned_int

  # An object inside a Verilog simulation (see *vpiHandle* in IEEE Std. 1364-2005).
  # * Learn how to read and write values to handles in the user manual.
  class Handle
    include Vpi

    # inherit Enumerable methods, such as #each, #map, #select, etc.
    # our version of these methods accept a list of VPI type constants (see #[])
      Enumerable.instance_methods.each do |meth|
        # using a string because define_method does not accept a block until Ruby 1.9
        class_eval %{
          def #{meth} *args, &block
            self[*args].send(:#{meth}, &block)
          end
        }
      end

    # Tests if the logic value of this handle is "don't care" (x).
    def x?
      self.hexStrVal =~ /x/i
    end

    # Tests if the logic value of this handle is high impedance (z).
    def z?
      self.hexStrVal =~ /z/i
    end

    # Reads the value using the given format and returns a +S_vpi_value+ object.
    def get_value_wrapper aFormat
      val = S_vpi_value.new
      val.format = aFormat

      vpi_get_value self, val
      val
    end

    # Reads the value using the given format and returns it. If a format is not given, then the Verilog simulator will attempt to determine the correct format.
    def get_value aFormat = VpiObjTypeVal
      val = get_value_wrapper(aFormat)

      case val.format
        when VpiBinStrVal, VpiOctStrVal, VpiDecStrVal, VpiHexStrVal, VpiStringVal
          val.value.str

        when VpiScalarVal
          val.value.scalar

        when VpiIntVal
          get_value_wrapper(VpiHexStrVal).value.str.to_i(16)

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

    # Writes the given value using the given format, time, and delay, and then returns the given value. If a format is not given, then the Verilog simulator will attempt to determine the correct format.
    def put_value aValue, aFormat = nil, aTime = nil, aDelay = VpiNoDelay
      aFormat ||= get_value_wrapper(VpiObjTypeVal).format

      newVal = S_vpi_value.new
      newVal.format = aFormat

      case aFormat
        when VpiBinStrVal, VpiOctStrVal, VpiDecStrVal, VpiHexStrVal, VpiStringVal
          newVal.value.str = aValue.to_s

        when VpiScalarVal
          newVal.value.scalar = aValue

        when VpiIntVal
          newVal.format = VpiHexStrVal
          newVal.value.str = aValue.to_i.to_s(16)

        when VpiRealVal
          newVal.value.real = aValue.to_f

        when VpiTimeVal
          newVal.value.time = aValue

        when VpiVectorVal
          newVal.value.vector = aValue

        when VpiStrengthVal
          newVal.value.strength = aValue

        else
          raise "unknown S_vpi_value.format: #{newVal.format}"
      end

      vpi_put_value self, newVal, aTime, aDelay

      # ensure that value was written correctly
        readenVal = get_value(aFormat)

        writtenCorrectly =
          case aFormat
            when VpiBinStrVal, VpiOctStrVal, VpiDecStrVal, VpiHexStrVal
              if aValue =~ /[xz]/i  # TODO: verify 'z' behavior
                readenVal =~ /[xz]/i
              else
                readenVal == aValue.to_s
              end

            when VpiStringVal
              readenVal == aValue.to_s

            when VpiIntVal
              # allow for register overflow when limit reached
              readenVal == (aValue.to_i % (2 ** self.vpiSize))

            when VpiRealVal
              readenVal == aValue.to_f

            else
              true
          end

        unless writtenCorrectly
          raise "value written (#{aValue.inspect}) does not match value read (#{readenVal.inspect}) from handle #{self}"
        end

      aValue
    end

    # Returns an array of child handles of the given VPI type names or VPI type constants. For example, the name 'reg' and the constant 'VpiReg' both access child handles that are registers.
    def [] *aTypes
      handles = []

      aTypes.each do |t|
        # resolve type names into type constants
          unless t.is_a? Integer
            t = @@propCache[t.to_sym].type
          end

        if itr = vpi_iterate(t, self)
          while h = vpi_scan(itr)
            handles << h
          end
        end
      end

      handles
    end

    # Inspects the given VPI property names in addition to those common to all handles. The same rules for accessing a handle's VPI properties (by calling methods) apply to the given property names. Thus, you can specify 'intVal' instead of 'VpiIntVal', and so on.
    def inspect *aPropNames
      aPropNames.unshift :fullName, :size, :file, :lineNo

      aPropNames.map! do |name|
        "#{name}=#{self.send(name.to_sym)}"
      end

      "#<Vpi::Handle #{vpiType_s} #{aPropNames.join(', ')}>"
    end

    alias to_s inspect


    @@propCache = Hash.new {|h, k| h[k] = Property.resolve(k)}

    # Enables access to (1) child handles and (2) VPI properties of this handle through method calls. In the case that a child handle has the same name as a VPI property, the child handle will be accessed instead of the VPI property. However, you can still access the VPI property via #get_value and #put_value.
    def method_missing aMsg, *aArgs, &aBlockArg
      if child = vpi_handle_by_name(aMsg.to_s, self)
        # cache the child for future accesses, in order to cut down number of calls to method_missing
          (class << self; self; end).class_eval do
            define_method aMsg do
              child
            end
          end

        child

      else
        prop = @@propCache[aMsg]

        if prop.operation
          self.send(prop.operation, prop.type, *aArgs, &aBlockArg)

        else
          case prop.accessor
            when :d	# delay values
              raise NotImplementedError, 'processing of delay values is not yet implemented.'
              # TODO: vpi_put_delays
              # TODO: vpi_get_delays

            when :l	# logic values
              if prop.assignment
                value = aArgs.shift
                put_value(value, prop.type, *aArgs)
              else
                get_value(prop.type)
              end

            when :i	# integer values
              vpi_get(prop.type, self) unless prop.assignment

            when :b # boolean values
              unless prop.assignment
                value = vpi_get(prop, self)
                value && (value != 0)	# zero is false in C
              end

            when :s	# string values
              vpi_get_str(prop.type, self) unless prop.assignment

            when :h	# handle values
              vpi_handle(prop.type, self) unless prop.assignment

            else
              raise NoMethodError, "unable to access VPI property #{prop.name.inspect} through method #{aMsg.inspect} with arguments #{aArgs.inspect} for handle #{self}"
          end
        end
      end
    end

    Property = Struct.new :type, :name, :operation, :accessor, :assignment

    # Resolves the given shorthand name into its VPI property.
    def Property.resolve aName
      # parse the given property name
        tokens = aName.to_s.split(/_/)


        tokens.last.sub!(/[\?!=]$/, '')

        addendum = $&
        isAssign = $& == '='
        isQuery = $& == '?'


        tokens.last =~ /^[a-z]$/ && tokens.pop
        accessor = $&

        name = tokens.pop

        operation =
          unless tokens.empty?
            tokens.join('_') << (addendum || '')
          end

      # determine the VPI integer type for the property
        name = name[0, 1].upcase << name[1..-1]
        name.insert 0, 'Vpi' unless name =~ /^[Vv]pi/

        begin
          type = Vpi.const_get(name)
        rescue NameError
          raise ArgumentError, "#{name.inspect} is not a valid VPI property"
        end

      accessor =
        if accessor
          accessor.to_sym

        else # infer accessor from VPI property name
          if isQuery
            :b

          else
            case name
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

      Property.new type, name, operation, accessor, isAssign
    end
  end
end
