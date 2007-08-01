# A small utility library.
#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

class String
  # Converts this string into a valid Ruby constant name.
  def to_ruby_const_name
    self[0, 1].upcase << self[1..-1]
  end

  # Strips off everything after the given character in this string.
  def rstrip_from char
    sub(/#{char}[^#{char}]*$/, '')
  end
end
