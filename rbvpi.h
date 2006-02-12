/*
	Copyright 2006 Suraj Kurapati
	Copyright 1999 Kazuhiro HIWADA

	This file is part of Ruby-VPI.

	Ruby-VPI is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	Ruby-VPI is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA	 02110-1301	 USA
*/
/**\file
	VPI module, used by Ruby code.
*/

#ifndef RBVPI_H
#define RBVPI_H

	#include <ruby.h>
	#include "relay.hin"
	#include "vlog.hin"


	/**
		A hash of task names and their associated procs.
		@see	rbvpi_register_systf
	*/
	static VALUE g_rTaskRegistry = Qnil;

	/**
		Creates and registers the VPI module with Ruby, so that Ruby code can use it.
	*/
	void Init_vpi();

	/**
		Transfers control from Ruby code to Verilog code.
	*/
	static VALUE rbvpi_relay_verilog(VALUE rSelf);


	/**
		Registers a VPI task with the given name and associates it with the given Ruby block.

		For example, to register a VPI task named "$hello_world" to a Ruby block which prints the text "hello world", you can do:
			<tt>VPI::register_systf("$hello_world") { puts "hello world" }</tt>

		@param	rTaskName	The name of the VPI task you wish to register. For example, "$hello_world".

		@arg	A block must also be given. This block will be invoked whenever the given task name is called by Verilog code.

		@throw	An ArgumentError if a block is not given.
	*/
	static VALUE rbvpi_register_systf(VALUE rSelf, VALUE rTaskName);

#endif
