/*
  Copyright 2006 Suraj N. Kurapati
  See the file named LICENSE for details.
*/
/**\file
  A proxy for all Verilog headers of interest to us.
*/

#ifndef VERILOG_H
#define VERILOG_H

  /*
    Use our verbatim copy of the official IEEE Std. 1364-2005 header file, which
    was obtained from this URL:
    <http://www.boydtechinc.com/ptf/archive/ptf_2005/0737.html>
  */
  #include "vpi_user.h"

  /*
    Adjust for the peculiarities of the Verilog simulator being used.
  */
  #ifdef SYNOPSYS_VCS
    #define VERILOG_LENIENT
  #endif

  /*
    Do we want to enforce strict compliance with IEEE Std. 1364-2001? If so,
    Ruby-VPI might not work with Synopsys VCS, but that's not our fault. ;-)
  */
  #define verilog_tf_funcPtr_strict(aPtrName) \
    PLI_INT32 (*aPtrName)(PLI_BYTE8*)

  #ifdef VERILOG_LENIENT
    #define verilog_tf_funcPtr(aPtrName) \
      void (*aPtrName)(void)

    #define verilog_tf_funcSig(aFuncName) \
      void aFuncName(void)

    #define verilog_tf_funcReturn(aReturnVal) \
      ;
  #else
    #define verilog_tf_funcPtr verilog_tf_funcPtr_strict

    #define verilog_tf_funcSig(aFuncName) \
      PLI_INT32 aFuncName(PLI_BYTE8* aCallbackData)

    #define verilog_tf_funcReturn(aReturnVal) \
      return aReturnVal
  #endif


  #define verilog_cb_funcPtr(aPtrName) \
    PLI_INT32 (*aPtrName)(p_cb_data)

  #define verilog_cb_funcSig(aFuncName) \
    PLI_INT32 aFuncName(p_cb_data aCallbackData)

  #define verilog_cb_funcReturn(aReturnVal) \
    return aReturnVal

#endif
