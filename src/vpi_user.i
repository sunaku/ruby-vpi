%module vpi
%{
/* Includes the header in the wrapper code */
#include "vpi_user.h"
%}

/* Parse the header file to generate wrappers */
%include "vpi_user.h"
