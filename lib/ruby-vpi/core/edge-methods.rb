# Defines methods for detecting all possible value changes.
#--
# Copyright 2007 Suraj N. Kurapati
# See the file named LICENSE for details.

DETECTION_METHODS = []
Method = Struct.new :name, :info, :body

vals  = %w[1 0 X Z H L t f]
edges = vals.map {|a| vals.map {|b| a + b}}.flatten

edges.each do |edge|
  name = "change_#{edge.downcase}?"
  old, new = edge.tr('tf', '10').split(//).map {|s| 'Vpi' + s}

  info = "Tests if the logic value of this handle has changed from #{old} (in the previous time step) to #{new} (in the current time step)."

  body = %{
    def #{name}
      old = @__edge__prev_val
      new = get_value(VpiScalarVal)

      old == #{old} && new == #{new}
    end
  }

  DETECTION_METHODS << Method.new(name, info, body)
end
