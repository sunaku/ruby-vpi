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

class String
  # Converts this string into a floating point number using the given radix.
  # The default radix is 10.
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
