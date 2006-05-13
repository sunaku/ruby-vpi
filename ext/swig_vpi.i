%module vpi
%{
/* Includes the header in the wrapper code */
#include "swig_vpi.h"
%}

/* Parse the header file to generate wrappers */
%include "swig_vpi.h"
