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
	This class represents an object inside a Verilog simulation. Such an object is known as a _handle_ in Verilog jargon. See *vpiHandle* in IEEE Std. 1364-2005 for details.

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
	You can read and write values directly, while implicitly specifying their format, through several shortcut methods. The names of these methods can be determined by (1) taking the name of a VPI value format listed in the *VALUE_FORMAT_NAMES* array, (2) removing the "Vpi" prefix, and (3) converting the first character into lower-case.

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

		HINT_REGEXP = %r{_([a-z])$}
		ASSIGN_REGEXP = %r{=$}
		PREFIX_REGEXP = %r{^(.*?)_}

		# Enables read and write access to VPI properties of this handle.
		def method_missing aMethId, *aMethArgs, &aMethBlock
			methName = aMethId.to_s

			# determine if property is being written
				assign = methName =~ ASSIGN_REGEXP
				methName.sub! ASSIGN_REGEXP, ''

			# parse operation prefix
				methName =~ PREFIX_REGEXP
				prefix = $1

				methName.sub! PREFIX_REGEXP, ''

			# parse operation hint
				methName =~ HINT_REGEXP
				hint = $1

				methName.sub! HINT_REGEXP, ''

			# resolve VPI identifier of property
				propName = methName[0, 1].upcase << methName[1..-1]
				propName.insert(0, 'Vpi') unless methName =~ /^vpi/

				prop = Kernel.const_get(propName)

				puts '', Kernel.caller.join("\n"), '', "prefix: #{prefix}", "meth: #{aMethId}", "args: #{aMethArgs.inspect}", "name: #{methName}", "prop: #{propName} => #{prop}", "assign: #{assign}" if $DEBUG

			# preform operation based on prefix
				case prefix
					when 'each'
						return each(prop, *aMethArgs, &aMethBlock)

					else
						# perform operation based on hint
							loop do
								puts "looping, hint: #{hint}" if $DEBUG

								case hint
									# delay values
									when 'd'

									# logic values
									when 'l'
										if assign
											value = aMethArgs.shift
											return put_value(value, prop, *aMethArgs)
										else
											return get_value(prop)
										end

									# integer & boolean values
									when 'i', 'b'
										if assign
											# put_value prop, *aMethArgs
										else
											return vpi_get(prop, self)
										end

									# string values
									when 's'
										if assign
											# put_value prop, *aMethArgs
										else
											return vpi_get_str(prop, self)
										end

									# handle values
									when 'h'
										if assign
											# put_value prop, *aMethArgs
										else
											return vpi_handle(prop, self)
										end

									else
										# hint not given. infer desired operation from property name
											case propName
												when /Delay$/
													hint = 'd'
													redo

												when /Val$/
													hint = 'l'
													redo

												when /Type$/
													hint = 'i'
													redo

												when /Name$/
													hint = 's'
													redo
											end
								end

								break
							end
				end

			raise NoMethodError, "unknown property `#{aMethId}' accessed with arguments `#{aMethArgs.inspect}'"
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

=begin
		def to_s
			name = vpi_get_str(VpiFullName, self)

			values = VALUE_FORMAT_NAMES.inject([]) do |acc, fmt|
				acc << "#{fmt}=#{get_value Vpi.module_eval(fmt.to_s)}"
			end.join(', ')

			"\#<VpiHandle(#{name}) #{values}>"
		end
=end
	end
end
