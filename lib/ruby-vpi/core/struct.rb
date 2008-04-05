# VPI structures (S_vpi_* and S_cb_*) stuff
#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

module VPI
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
    # Attempts to detect the format of the given value.
    # Returns +nil+ if detection is not possible.
    def self.detect_format aValue
      if aValue.respond_to? :to_int
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
      end
    end

    # Writes the given value, which has the given format.
    def write aValue, aFormat
      case aFormat
      when VpiBinStrVal, VpiOctStrVal, VpiDecStrVal, VpiHexStrVal, VpiStringVal
        value.str      = aValue.to_s

      when VpiScalarVal
        value.scalar   = aValue.to_i

      when VpiIntVal
        value.integer  = aValue.to_i

      when VpiRealVal
        value.real     = aValue.to_f

      when VpiTimeVal
        value.time     = aValue

      when VpiVectorVal
        value.vector   = aValue

      when VpiStrengthVal
        value.strength = aValue

      else
        raise "unknown format: #{aFormat.inspect}"
      end
    end

    # Returns the value in the given format.
    def read aFormat = self.format
      case aFormat
      when VpiBinStrVal, VpiOctStrVal, VpiDecStrVal, VpiHexStrVal, VpiStringVal
        value.str.to_s

      when VpiScalarVal
        value.scalar.to_i

      when VpiIntVal
        value.integer.to_i

      when VpiRealVal
        value.real.to_f

      when VpiTimeVal
        value.time

      when VpiVectorVal
        value.vector

      when VpiStrengthVal
        value.strength

      else
        raise "unknown format: #{aFormat.inspect}"
      end
    end
  end

  # make VPI structs more accessible by allowing their
  # members to be initialized through the constructor
  constants.grep(/^S_/).each do |s|
    const_get(s).class_eval do
      alias __struct__initialize initialize

      def initialize aMembers = {} #:nodoc:
        __struct__initialize

        aMembers.each_pair do |k, v|
          __send__("#{k}=", v)
        end
      end
    end
  end
end
