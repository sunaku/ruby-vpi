# Library for hardware-related floating point operations.
#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

class String
  # Converts this string into a floating point number
  # using the given radix. The default radix is 10.
  def to_f aRadix = 10
    whole, frac = split('.', 2)
    whole = whole.to_i(aRadix).to_f

    if frac
      f = 0.0

      frac.length.times do |i|
        power = i.next
        weight = aRadix ** -power
        digit = frac[i, 1].to_i(aRadix)

        f += digit * weight
      end

      f = -f if self =~ /^-/
      whole += f
    end

    whole
  end
end

class Float
  # Returns the mantissa of this floating point number
  def mantissa
    f = abs
    f - f.floor
  end
end
