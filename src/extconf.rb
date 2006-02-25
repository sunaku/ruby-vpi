=begin
	Copyright 2006 Suraj Kurapati

	This file is part of Ruby-VPI.

	Ruby-VPI is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	Ruby-VPI is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
=end

require 'mkmf'


# Verilog and POSIX threads
dir_config('verilog')

exit(1) unless
	have_header('vpi_user.h') &&
	have_library('pthread', 'pthread_create')


# SystemVerilog
if have_macro('vpiAggregateVal', 'vpi_user.h')
	$defs << "-DHAVE_VPIAGGREGATEVAL"
end


create_makefile('ruby-vpi')
