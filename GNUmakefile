# Copyright 2006 Suraj Kurapati

# This file is part of Ruby-VPI.

# Ruby-VPI is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

# Ruby-VPI is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA


cflags = `ruby -r mkmf -e 'cflags = $$configure_args["--cflags"]; puts cflags unless cflags.nil?'`	# cflags with which Ruby was compiled on your system
cflags += -g -DDEBUG $(CFLAGS)


all: ruby-vpi

clean: ruby-vpi-clean


dist: all
	cd doc && make
	cd samp && make

distclean: clean
	cd doc && make clean
	cd samp && make clean


ruby-vpi: Makefile
	make -f Makefile

Makefile:
	ruby src/extconf.rb --with-cflags="$(cflags)" --with-verilog-dir="$(VERILOG)" $(OPTIONS)

ruby-vpi-clean:
	make -f Makefile clean || true
	rm -f Makefile mkmf.log
