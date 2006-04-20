%module vpi
%{
/* Includes the header in the wrapper code */
#include "verilog.h"
#include "vpi_user.h"
%}

/* Parse the header file to generate wrappers */
%include "verilog.h"
%include "vpi_user.h"
