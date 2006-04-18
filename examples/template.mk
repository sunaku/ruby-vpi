# A template to simplify makefiles for examples.

make_deps = cd $(top_dir) && make
vcs_table = $(top_dir)/examples/synopsys_vcs.tab

LIB_RUBY = -lruby
LIB_PTHREAD = -lpthread


all: deps

clean: deps-clean ivl-clean vcs-clean msim-clean


deps:
	$(make_deps)
	cp $(top_dir)/src/VPI.rb .

deps-clean:
	$(make_deps) clean
	rm -f VPI.rb


# Icarus Verilog
ivl: deps
	cp $(top_dir)/ruby-vpi.so ruby-vpi.vpi
	iverilog -y. -mruby-vpi $(src_files)
	vvp -M. a.out

ivl-clean:
	rm -f ruby-vpi.vpi a.out


# Synopsys VCS
vcs:
	make deps CFLAGS="-DSYNOPSYS_VCS"
	vcs -R +v2k +vpi -LDFLAGS "$(top_dir)/../ruby-vpi.o $(LIB_RUBY) $(LIB_PTHREAD)" $(VCS_FLAGS) -P $(vcs_table) $(src_files)

vcs-clean:
	rm -rf csrc simv*


# Mentor ModelSim
msim: deps
	vlib work
	vlog $(src_files)
	vsim -c $(src_module) -pli $(top_dir)/ruby-vpi.so -do "run -all"

msim-clean:
	rm -rf work
