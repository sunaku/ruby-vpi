=begin
	Copyright 2006 Suraj Kurapati

  This file is part of Ruby-VPI.

	Ruby-VPI is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

	Ruby-VPI is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
=end

# Ruby interface to the Ruby-VPI extension.
module VPI
	CONTROLS = [:stop, :finish, :reset].freeze

	# Controls the Verilog simulation. Same as $vpi_control()
	def control(how, *args)
		raise ArgumentError, "invalid action: #{how}; valid actions are: #{CONTROLS.join(', ')}" unless CONTROLS.include? how
		self.send how, *args
	end

	alias_method :vpi_control, :control
	module_function :vpi_control, :control
end
