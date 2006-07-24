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
	along with Ruby-VPI; if not, write to the Free Software Foundation,
	Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
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
		QUERY_REGEXP = %r{\?$}
		PREFIX_REGEXP = %r{^(.*?)_}

		# Enables read and write access to VPI properties of this handle.
		def method_missing aMsg, *aArgs, &aBlockArg
			methName = aMsg.to_s

			# determine if property is being written
				if isAssign = methName =~ ASSIGN_REGEXP
					methName.sub! ASSIGN_REGEXP, ''
				end

			# determine if property is being queried
				if isQuery = methName =~ QUERY_REGEXP
					methName.sub! QUERY_REGEXP, ''
				end

			# parse Accessor parameter
				if accessor = methName[HINT_REGEXP, 1]
					methName.sub! HINT_REGEXP, ''
				end

			# parse Operation parameter
				if operation = methName[PREFIX_REGEXP, 1]
					methName.sub! PREFIX_REGEXP, ''
				end

			# resolve Property parameter into a valid VPI property
				propName = methName[0, 1].upcase << methName[1..-1]
				propName.insert(0, 'Vpi') unless methName =~ /^vpi/

				puts '', Kernel.caller.join("\n"), '', "operation: #{operation}", "meth: #{aMsg}", "args: #{aArgs.inspect}", "name: #{methName}", "prop: #{propName}", "assign: #{isAssign}", "query: #{isQuery}" if $DEBUG

				begin
					prop = Vpi.const_get(propName)
				rescue NameError
					raise ArgumentError, "invalid VPI property `#{propName}'"
				end

			# access the VPI property
				if operation
					return self.send(operation.to_sym, prop, *aArgs, &aBlockArg)
				else
					loop do
						puts "looping, accessor: #{accessor}" if $DEBUG

						case accessor
							when 'd'	# delay values
								if isAssign
									# TODO: vpi_put_delays
								else
									# TODO: vpi_get_delays
								end

							when 'l'	# logic values
								if isAssign
									value = aArgs.shift
									return put_value(value, prop, *aArgs)
								else
									return get_value(prop)
								end

							when 'i', 'b'	# integer values
								return vpi_get(prop, self) unless isAssign

							when 'b'	# boolean values
								unless isAssign
									value = vpi_get(prop, self)
									return value && (value != 0)	# zero is false in C
								end

							when 's'	# string values
								return vpi_get_str(prop, self) unless isAssign

							when 'h'	# handle values
								return vpi_handle(prop, self) unless isAssign

							else	# accessor not specified. guess its value from property name
								if isQuery
									accessor = 'b'
									redo
								end

								case propName
									when /Time$/
										accessor = 'd'
										redo

									when /Val$/
										accessor = 'l'
										redo

									when /Type$/, /Direction$/, /Index$/, /Size$/, /Strength\d?$/, /Polarity$/, /Edge$/, /Offset$/, /Mode$/
										accessor = 'i'
										redo

									when /Is[A-Z]/, /ed$/
										accessor = 'b'
										redo

									when /Name$/, /File$/, /Decompile$/
										accessor = 's'
										redo

									when /Parent$/, /Inst$/, /Range$/, /Driver$/, /Net$/, /Load$/, /Conn$/, /Bit$/, /Word$/, /[LR]hs$/, /(In|Out)$/, /Term$/, /Argument$/, /Condition$/, /Use$/, /Operand$/, /Stmt$/, /Expr$/, /Scope$/, /Memory$/, /Delay$/
										accessor = 'h'
										redo
								end
						end

						break
					end
				end

			raise NoMethodError, "unable to access VPI property `#{propName}' through method `#{aMsg}' with arguments `#{aArgs.inspect}' for handle #{self}"
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
	end
end
