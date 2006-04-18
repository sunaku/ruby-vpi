# A template to simplify makefiles for examples.

make_deps = cd $(top_dir) && make
vcs_table = $(top_dir)/sample/synopsys_vcs.tab


all: deps

clean: deps-clean ivl-clean vcs-clean vsim-clean


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
	vcs -R +v2k +vpi -LDFLAGS "$(top_dir)/../ruby-vpi.o -lruby -lpthread" $(VCS_FLAGS) -P $(vcs_table) $(src_files)

vcs-clean:
	rm -rf csrc simv*


# Mentor ModelSim
vsim: deps
	vlib work
	vlog $(src_files)
	vsim -c $(src_module) -pli $(top_dir)/ruby-vpi.so -do "run -all"

vsim-clean:
	rm -rf work
