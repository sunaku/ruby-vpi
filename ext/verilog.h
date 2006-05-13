/*
	Copyright 2006 Suraj N. Kurapati

	This file is part of Ruby-VPI.

	Ruby-VPI is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

	Ruby-VPI is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/
/**\file
	A proxy for all Verilog headers of interest to us.
*/

#ifndef VERILOG_H
#define	VERILOG_H

	// Use our verbatim copy of the official IEEE Std. 1364-2005 header file, which was obtained from this URL: <http://www.boydtechinc.com/ptf/archive/ptf_2005/0737.html>
	#include "vpi_user.h"


	// Adjust for the peculiarities of the Verilog simulator being used.
	#ifdef SYNOPSYS_VCS
		#define VERILOG_LENIENT
	#endif

	// Do we want to enforce strict compliance with IEEE Std. 1364-2001? If so, Ruby-VPI might not work with Synopsys VCS, but that's not our fault. ;-)
	#define verilog_tf_funcPtr_strict(aPtrName)	\
		PLI_INT32 (*aPtrName)(PLI_BYTE8*)

	#ifdef VERILOG_LENIENT
		#define verilog_tf_funcPtr(aPtrName)	\
			void (*aPtrName)(void)

		#define verilog_tf_funcSig(aFuncName)	\
			void aFuncName(void)

		#define verilog_tf_funcReturn(aReturnVal) \
			;
	#else
		#define verilog_tf_funcPtr verilog_tf_funcPtr_strict

		#define verilog_tf_funcSig(aFuncName)	\
			static PLI_INT32 aFuncName(PLI_BYTE8* aDummy)

		#define verilog_tf_funcReturn(aReturnVal)	\
			return aReturnVal
	#endif

#endif
