class String
  # Converts this string into a valid Ruby constant name.
  def to_ruby_const_name
    self[0, 1].upcase << self[1..-1]
  end

  def rstrip_from a
    sub(/#{a}[^#{a}]*$/, '')
  end
end