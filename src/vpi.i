%module vpi
%{
/* Includes the header in the wrapper code */
#include "vpi.h"
%}

/* Parse the header file to generate wrappers */
%include "vpi.h"
