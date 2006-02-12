# Copyright 2006 Suraj Kurapati

# This file is part of Ruby-VPI.

# Ruby-VPI is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# Ruby-VPI is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA	 02110-1301	 USA

all: ruby-vpi docs test

ruby-vpi:
	ruby extconf.rb
	make -f Makefile

test: icarus-verilog synopsys-vcs mentor-modelsim

icarus-verilog: ruby-vpi
	cp ruby-vpi.so ruby-vpi.vpi
	iverilog -y. -mruby-vpi vpi_test.v
	vvp -M. a.out

synopsys-vcs: ruby-vpi
	echo to do

mentor-modelsim: ruby-vpi
	vlib work
	vlog vpi_test.v
	vsim -pli ruby-vpi.so -do 'run -all'

docs:
	doxygen

clean:
	make -f Makefile clean
	rm -f Makefile mkmf.log	# for extconf.rb


	rm -f ruby-vpi.vpi a.out	# for icarus-verilog
	rm -rf html	# for doxygen
