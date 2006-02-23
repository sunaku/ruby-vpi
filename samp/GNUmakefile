# Copyright 2006 Suraj Kurapati

# This file is part of Ruby-VPI.

# Ruby-VPI is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

# Ruby-VPI is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

all: deps

clean: deps-clean ivl-clean vcs-clean vsim-clean


deps:
	cd .. && make

deps-clean:
	cd .. && make clean


# Icarus Verilog
ivl: deps
	cp ../ruby-vpi.so ruby-vpi.vpi
	iverilog -y. -mruby-vpi test.v counter.v
	vvp -M. a.out

ivl-clean:
	rm -f ruby-vpi.vpi a.out


# Synopsys VCS
vcs: deps
	# TODO: check if this works
	vcs +v2k +vpi -LDFLAGS "../../ruby-vpi.so" -P test.tab test.v counter.v
	./simv

vcs-clean:
	rm -f simv


# Mentor ModelSim
vsim: deps
	vlib work
	vlog test.v counter.v
	vsim -c test -pli ../ruby-vpi.so -do 'run -all'

vsim-clean:
	rm -rf work
