/*
  Copyright 1999 Kazuhiro HIWADA
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
*/

#include "vlog.h"
#include "relay.h"


s_cb_data* vlog__relayReason = NULL;

verilog_cb_funcSig(vlog_relay_init) {
  relay_init();
  verilog_cb_funcReturn(0);
}

verilog_cb_funcSig(vlog_relay_ruby) {
  vlog__relayReason = aCallbackData;
  relay_ruby();

  verilog_cb_funcReturn(0);
}

s_cb_data* vlog_relay_ruby_reason() {
  return vlog__relayReason;
}


/**
  Registers a callback at start of simulation to vlog_relay_main();
*/
void vlog_startup() {
  s_cb_data call;

  call.reason = cbStartOfSimulation;
  call.cb_rtn = vlog_relay_init;
  call.obj = NULL;
  call.time = NULL;
  call.value = NULL;
  call.user_data = NULL;

  vpi_free_object(vpi_register_cb(&call));
}

void (*vlog_startup_routines[])() = { vlog_startup, NULL };

#if defined(PRAGMATIC_CVER) || defined(SYNOPSYS_VCS)
  /**
    Invokes each routine specified in the vlog_startup_routines array.

    This code is originally from GPL Cver 2.11a:
    Copyright (c) 1991-2005 Pragmatic C Software Corp.
  */
  void vlog_startup_routines_bootstrap() {
    unsigned int i;
    for (i = 0; vlog_startup_routines[i] != NULL; i++)
      vlog_startup_routines[i]();
  }
#endif
