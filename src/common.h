/*
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
*/
/**\file
	Things common to our code.
*/

#ifndef COMMON_H
#define	COMMON_H

	#include "verilog.h"


	/**
		A wrapper for vpi_printf() which marks the given message as being emitted from Ruby-VPI and ends the message with a new line.

		@param	...	Arguments to vpi_printf()
	*/
	#define common_printf(...)	vpi_printf("Ruby-VPI: "); vpi_printf(__VA_ARGS__); vpi_printf("\n");

	/**
		A wrapper for common_printf() which marks the given message as being debugging output.
	*/
	#define common_debug(...) vpi_printf("(%s:%d) ", __FILE__, __LINE__); common_printf(__VA_ARGS__);

#endif
