# Wrappers which transform the VPI interface into one that is more suitable for Ruby.

=begin
	Copyright 2006 Suraj Kurapati

  This file is part of Ruby-VPI.

	Ruby-VPI is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

	Ruby-VPI is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
=end

module Vpi
end

module SWIG
	# A wrapper for the +vpiHandle+ object.
	class TYPE_p___vpiHandle
		include Vpi

		def get_value(aFormat = VpiObjTypeVal)
			val = S_vpi_value.new
			val.format = aFormat

			vpi_get_value self, val
			val
		end

		def value(*args)
			val = get_value(*args)

			case val.format
				when VpiBinStrVal, VpiOctStrVal, VpiDecStrVal, VpiHexStrVal, VpiStringVal
					val.value.str

				when VpiScalarVal
					val.value.scalar

				when VpiIntVal
					val.value.integer

				when VpiRealVal
					val.value.real

				when VpiTimeVal
					val.value.time

				when VpiVectorVal
					val.value.vector

				when VpiStringVal
					val.value.strength

				else
					raise
			end
		end

		def put_value(aValue, aFormat = nil, aTime = nil, aDelay = VpiNoDelay)
			newVal = S_vpi_value.new
			newVal.format = aFormat || self.get_value.format

			case newVal.format
				when VpiBinStrVal, VpiOctStrVal, VpiDecStrVal, VpiHexStrVal, VpiStringVal
					newVal.value.str = aValue

				when VpiScalarVal
					newVal.value.scalar = aValue

				when VpiIntVal
					newVal.value.integer = aValue

				when VpiRealVal
					newVal.value.real = aValue

				when VpiTimeVal
					newVal.value.time = aValue

				when VpiVectorVal
					newVal.value.vector = aValue

				when VpiStringVal
					newVal.value.strength = aValue

				else
					raise
			end

			vpi_put_value self, newVal, aTime, aDelay
		end

		alias_method :'value=', :put_value
	end
end
