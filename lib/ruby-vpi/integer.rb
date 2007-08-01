# Library for hardware-related integer operations.
#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

# NOTE: Because integers are _immediate_ values in Ruby, these methods *cannot*
# modify the value of the integer upon which they are invoked. Instead, they
# return the new value as their result.
class Integer
  # Returns the ceiling of the logarithm (base 2) of this positive integer.
  def log2
    raise "integer must be positive" if self < 0
    bin = to_s(2)

    if bin =~ /^10+$/
      bin.length - 1
    else
      bin.length
    end
  end

  # Returns the minimum number of bits necessary to represent this integer.
  def length
    to_s(2).length
  end

  # Returns the lowest upper-bound of this integer. This integer cannot reach
  # the limit without occupying more bits in its binary representation.
  def limit
    length.to_limit
  end

  # Returns the lowest upper-bound of an integer with *this* number of bits.
  def to_limit
    2 ** self
  end


  # Returns a bit-mask capable of masking this integer.
  def mask
    length.to_mask
  end

  # Returns a bit-mask capable of masking an integer with *this* number of bits.
  def to_mask
    to_limit - 1
  end


  # Returns the maximum value representable by this integer without occupying
  # more bits in its binary representation.
  alias max mask

  # Returns the maximum value representable by an integer with *this* number of
  # bits.
  alias to_max to_mask


  # Transforms this infinite-length Ruby integer into a fixed-length integer
  # (represented in two's complement form) that has the given width (number of
  # bits).
  def pack aPackedWidth
    bits = length
    bits += 1 if self > 0 # positive integers also have a sign bit (zero)

    unless aPackedWidth >= bits
      raise ArgumentError, "packed width #{aPackedWidth} must be at least #{bits} for integer #{self}"
    end

    extend_sign(bits, aPackedWidth)
  end

  # Transforms this fixed-length integer (represented in two's complement form)
  # that has the given width (number of bits) into an infinite-length Ruby
  # integer.
  def unpack aPackedWidth
    bits = length

    unless aPackedWidth >= bits
      raise ArgumentError, "packed width #{aPackedWidth} must be at least #{bits} for integer #{self}"
    end

    mask = aPackedWidth.to_mask
    result = self & mask

    if result[aPackedWidth - 1] == 1
      -((-result) & mask)
    else
      result
    end
  end


  # Performs sign extension on this integer, which has the given width (number
  # of bits), so that the result will have the given extended width (number of
  # bits).
  def extend_sign aOrigWidth, aExtWidth
    result = self
    maskWidth = aExtWidth - aOrigWidth

    if maskWidth > 0 && result[aOrigWidth - 1] == 1
      result |= (maskWidth.to_mask << aOrigWidth)
    end

    result & aExtWidth.to_mask
  end

  # Splits this integer into an array of smaller integers, each of which have
  # the given positive, non-zero width (number of bits). These smaller integers
  # are ordered from left to right, in the same way that humans write unsigned
  # binary numbers; for example:
  #
  ## >> 6.split 1
  ## => [1, 1, 0]
  ## >> 6.split(1).map {|i| i.to_s 2}
  ## => ["1", "1", "0"]
  ## >> 6.split 2
  ## => [1, 2]
  ## >> 6.split(2).map {|i| i.to_s 2}
  ## => ["1", "10"]
  def split aWidth = 8
    raise ArgumentError, "width must be positive and non-zero" unless aWidth > 0

    int, bits = self, length
    mask = aWidth.to_mask
    words = []

    while bits > 0
      words.unshift int & mask
      int >>= aWidth
      bits -= aWidth
    end

    words
  end
end
