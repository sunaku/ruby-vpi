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
#include <stdlib.h>


verilog_tf_funcSig(vlog_ruby_init) {
  relay_init();
  relay_ruby_run();
  verilog_tf_funcReturn(0);
}

verilog_tf_funcSig(vlog_ruby_relay) {
  relay_ruby();
  verilog_tf_funcReturn(0);
}

void vlog_bind_task(PLI_BYTE8* apTaskName, verilog_tf_funcPtr(apTaskDef)) {
  s_vpi_systf_data tf;

  tf.type = vpiSysTask;
  tf.sysfunctype = 0;
  tf.tfname = apTaskName;
  tf.calltf = (verilog_tf_funcPtr_strict())apTaskDef;
  tf.compiletf = NULL;
  tf.sizetf = NULL;
  tf.user_data = NULL;

  vpi_register_systf(&tf);
}

/**
  Binds the default VPI tasks (provided by Ruby-VPI) before the Verilog simulator begins to simulate.
*/
void vlog_startup() {
  vlog_bind_task("$ruby_init", vlog_ruby_init);
  vlog_bind_task("$ruby_relay", vlog_ruby_relay);
}

void (*vlog_startup_routines[])() = { vlog_startup, 0 };

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
