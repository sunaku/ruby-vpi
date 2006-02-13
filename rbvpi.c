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
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <assert.h>
#include "rbvpi.h"

#include "relay.cin"
#include "vlog.cin"


void Init_vpi() {
	VALUE mVPI = rb_define_module("VPI");
	rb_define_singleton_method(mVPI, "relay_verilog", rbvpi_relay_verilog, 0);
	rb_define_singleton_method(mVPI, "register_task", rbvpi_register_task, 1);
}

static VALUE rbvpi_relay_verilog(VALUE rSelf) {
	relay_verilog();
	return Qnil;
}

static VALUE rbvpi_register_task(VALUE rSelf, VALUE rTaskName) {
	// create registry if necessary
	if(g_rTaskRegistry == Qnil) {
		g_rTaskRegistry = rb_hash_new();
	}


	VALUE rName = rb_str_to_str(rTaskName);
	PLI_BYTE8* name = (PLI_BYTE8*)StringValueCStr(rName);


	// raise if no block given
	if(!rb_block_given_p()) {
		rb_raise(rb_eArgError, "no block given for task: %s", name);
	}


	// raise if task name already registered
	if(rb_hash_aref(g_rTaskRegistry, rName) != Qnil) {
		rb_raise(rb_eArgError, "task has already been registered: %s", name);
	}


	// register the task
	VALUE rTask = rb_block_proc();	// convert the given block into a proc, which we can later call
	rb_hash_aset(g_rTaskRegistry, rName, rTask);
	assert(rb_hash_aref(g_rTaskRegistry, rName) == rTask);

	rbvpi_debug("in rbvpi_register_task(), registered task: %s", name);


	return rSelf;
}
