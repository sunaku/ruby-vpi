# Utility wrappers which transform the VPI interface into one that is more suitable for Ruby.

=begin
	Copyright 2006 Suraj Kurapati

  This file is part of Ruby-VPI.

	Ruby-VPI is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

	Ruby-VPI is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
=end

module SWIG
	# A VPI handle object (see +vpiHandle+ in IEEE Std. 1364-2005) which can represent any part of the simulation environment.
	#
	# = Reading and writing values
	# There are several ways to read and write a handle's value, depending on its representation.
	#
	# == Using +S_vpi_value+ objects
	# You can read and write values using +S_vpi_value+ objects through the following methods.
	# * #get_value_wrapper
	# * Vpi::vpi_get_value
	# * Vpi::vpi_put_value
	#
	# == Using values and formats
	# You can read and write values, while specifying their format, through the following methods.
	# * value = handle.#get_value(format)
	# * handle.#put_value(value, format)
	#
	# Another way to express the code shown above is:
	# * value = handle.#value(format)
	# * handle.#value = [value, format]
	#
	# == Using values directly
	# You can read and write values directly, while implicitly specifying their format, through several shortcut methods. The names of these methods can be determined by (1) taking the name of a VPI value format (see the #VALUE_FORMAT_NAMES array), (2) removing the "Vpi" prefix, and (3) converting the first character into lower-case.
	#
	# For example, the shortcut methods for reading and writing values using the <tt><b>Vpi</b><em>I</em>ntVal</tt> format are:
	# * intVal
	# * intVal=
	#
	# The methods shown above can be used like so:
	# * value = handle.#intVal
	# * handle.#intVal = value
	#
	# == Examples of all approaches
	# To read a handle's value as an integer:
	# * handle.#get_value(VpiIntVal)
	# * handle.#value(VpiIntVal)
	# * handle.intVal
	#
	# To write a handle's value as an integer:
	# * handle.#put_value(15, VpiIntVal)
	# * handle.#value = [15, VpiIntVal]
	# * handle.intVal = 15
	class TYPE_p_unsigned_int
		include Vpi

		# Names of VPI value formats. See <tt>S_vpi_value.format</tt> for details.
		VALUE_FORMAT_NAMES = [:VpiBinStrVal, :VpiOctStrVal, :VpiDecStrVal, :VpiHexStrVal, :VpiStringVal, :VpiScalarVal, :VpiIntVal, :VpiRealVal, :VpiTimeVal, :VpiVectorVal, :VpiStrengthVal].freeze

		# Create methods for reading and writing every VPI value format. These methods wrap the +value+ and +value=+ methods.
		VALUE_FORMAT_NAMES.each do |var|
			varName = var.to_s

			methName = varName.sub(%r{^Vpi}, '')
			methName[0] = methName[0].chr.downcase

			eval %{
				def #{methName}
					self.value #{varName}
				end

				def #{methName}= *aArgs
					aArgs[1, 0] = #{varName}
					self.put_value *aArgs.flatten
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
			val = get_value_wrapper aFormat

			case val.format
				when VpiBinStrVal
					val.value.str.to_i(2)

				when VpiOctStrVal
					val.value.str.to_i(8)

				when VpiDecStrVal
					val.value.str.to_i(10)

				when VpiHexStrVal
					val.value.str.to_i(16)

				when VpiStringVal
					val.value.str.dup

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

				when VpiStrengthVal
					val.value.strength

				else
					raise "unknown S_vpi_value.format: #{val.format}"
			end
		end

		alias_method :value, :get_value

		# Writes the given value using the given format, time, and delay. If a format is not given, then the Verilog simulator will attempt to determine the correct format.
		def put_value aValue, aFormat = nil, aTime = nil, aDelay = VpiNoDelay
			newVal = S_vpi_value.new
			newVal.format = aFormat || get_value_wrapper(VpiObjTypeVal).format

			case newVal.format
				when VpiBinStrVal
					newVal.value.str = aValue.to_s(2)

				when VpiOctStrVal
					newVal.value.str = aValue.to_s(8)

				when VpiDecStrVal
					newVal.value.str = aValue.to_s(10)

				when VpiHexStrVal
					newVal.value.str = aValue.to_s(16)

				when VpiStringVal
					newVal.value.str = aValue.dup

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

				when VpiStrengthVal
					newVal.value.strength = aValue

				else
					raise "unknown S_vpi_value.format: #{newVal.format}"
			end

			vpi_put_value self, newVal, aTime, aDelay
		end

		# Invokes #put_value by passing the contents of the given array as arguments.
		def value= *aArray
			put_value *aArray.flatten
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

		# Iterates over all handles of the given type.
		def each aType, &aBlock
			self[aType].each(&aBlock)
		end
	end
end
