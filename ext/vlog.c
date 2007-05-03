/*
  Copyright 1999 Kazuhiro HIWADA
  Copyright 2006 Suraj N. Kurapati
  See the file named LICENSE for details.
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

#if defined(PRAGMATIC_CVER) || defined(SYNOPSYS_VCS) || defined(CADENCE_NCSIM)
  /**
    Invokes each routine specified in the vlog_startup_routines array.
  */
  void vlog_startup_routines_bootstrap() {
    unsigned i;
    for (i = 0; vlog_startup_routines[i] != NULL; i++)
      vlog_startup_routines[i]();
  }
#endif
