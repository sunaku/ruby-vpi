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
	along with this program; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
=end

module SWIG
=begin rdoc
	Represents an object, known as a "handle", in the Verilog simulation environment. See +vpiHandle+ in IEEE Std. 1364-2005 for details.

	= Reading and writing values
	There are several ways to read and write a handle's value, depending on its representation.

	== Using +S_vpi_value+ objects
	You can read and write values using +S_vpi_value+ objects through the following methods.
	* #get_value_wrapper
	* Vpi::vpi_get_value
	* Vpi::vpi_put_value

	== Using values and formats
	You can read and write values, while specifying their format, through the following methods.
	* value = handle.#get_value(format)
	* handle.#put_value(value, format)

	== Using values directly
	You can read and write values directly, while implicitly specifying their format, through several shortcut methods. The names of these methods can be determined by (1) taking the name of a VPI value format (see the #VALUE_FORMAT_NAMES array), (2) removing the "Vpi" prefix, and (3) converting the first character into lower-case.

	For example, the shortcut methods for reading and writing values using the <tt><b>Vpi</b><em>I</em>ntVal</tt> format are:
	* intVal
	* intVal=

	The methods shown above can be used like so:
	* value = handle.#intVal
	* handle.#intVal = value

	== Examples of all approaches
	To read a handle's value as an integer:
	* handle.#get_value(VpiIntVal)
	* handle.intVal

	To write a handle's value as an integer:
	* handle.#put_value(15, VpiIntVal)
	* handle.intVal = 15
=end
	class TYPE_p_unsigned_int
		include Vpi

		# Names of VPI value formats. See <tt>S_vpi_value.format</tt> for details.
		VALUE_FORMAT_NAMES = [:VpiBinStrVal, :VpiOctStrVal, :VpiDecStrVal, :VpiHexStrVal, :VpiStringVal, :VpiScalarVal, :VpiIntVal, :VpiRealVal, :VpiTimeVal, :VpiVectorVal, :VpiStrengthVal].freeze

		# Create methods for reading and writing every VPI value format. These methods wrap the +value+ and +value=+ methods.
		VALUE_FORMAT_NAMES.each do |var|
			varName = var.to_s

			methName = varName.sub(/^Vpi/, '')
			methName[0] = methName[0].chr.downcase

			eval %{
				def #{methName}
					get_value #{varName}
				end

				def #{methName}= aValue, *aArgs
					put_value(aValue, #{varName}, *aArgs)
				end
			}
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

		# Writes the given value using the given format, time, and delay. If a format is not given, then the Verilog simulator will attempt to determine the correct format.
		def put_value aValue, aFormat = nil, aTime = nil, aDelay = VpiNoDelay
			newVal = S_vpi_value.new
			newVal.format = aFormat || get_value_wrapper(VpiObjTypeVal).format

			case newVal.format
				when VpiBinStrVal, VpiOctStrVal, VpiDecStrVal, VpiHexStrVal, VpiStringVal
					newVal.value.str = aValue

				when VpiScalarVal
					newVal.value.scalar = aValue

				when VpiIntVal
					newVal.format = VpiHexStrVal
					newVal.value.str = aValue.to_s(16)

				when VpiRealVal
					newVal.value.real = aValue

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
		end

		# Returns an array of handles of the given type.
		def [] aType
			handles = []

			if itr = vpi_iterate(aType, self)
				while h = vpi_scan(itr)
					handles << h
				end
			end

			handles
		end

		# Iterates over all handles of the given type and executes the given block once for each handle.
		def each aType, &aBlock	# :yields: handle
			self[aType].each(&aBlock)
		end

		def to_s
			name = vpi_get_str(VpiFullName, self)

			values = VALUE_FORMAT_NAMES.inject([]) do |acc, fmt|
				acc << "#{fmt}=#{get_value Vpi.module_eval(fmt.to_s)}"
			end.join(', ')

			"\#<VpiHandle(#{name}) #{values}>"
		end
	end
end
