# A template to simplify makefiles of Ruby-VPI test benches.

make_deps = cd $(RubyVpiPath) && make
vcs_table = $(RubyVpiPath)/examples/synopsys_vcs.tab

LIB_RUBY =  `ruby -r rbconfig -e 'puts %{-L#{Config::CONFIG["libdir"]} #{Config::CONFIG["LIBRUBYARG"]}}'`
LIB_PTHREAD = -lpthread


all: deps

clean: deps-clean ivl-clean vcs-clean vsim-clean


deps:
	$(make_deps)
	cp $(RubyVpiPath)/lib/vpi_util.rb $(RubyVpiPath)/lib/rspec.rb .

deps-clean:
	$(make_deps) clean
	rm -f vpi_util.rb rspec.rb


# Pragmatic C - Cver
cver:
	make -e deps CFLAGS="-DPRAGMATIC_CVER" LDFLAGS="-export-dynamic"
	cver $(CVER_FLAGS) +loadvpi=$(RubyVpiPath)/ruby-vpi.so:vlog_startup_routines_bootstrap $(src_files)

cver-clean:


# Icarus Verilog
ivl:
	make -e deps CFLAGS="-DICARUS_VERILOG"
	cp $(RubyVpiPath)/ruby-vpi.so ruby-vpi.vpi
	iverilog $(IVL_FLAGS) -y. -mruby-vpi $(src_files)
	vvp -M. a.out

ivl-clean:
	rm -f ruby-vpi.vpi a.out


# Synopsys VCS
vcs:
	make -e deps CFLAGS="-DSYNOPSYS_VCS"
	vcs $(VCS_FLAGS) -R +v2k +vpi -LDFLAGS "../$(RubyVpiPath)/ruby-vpi.o $(LIB_RUBY) $(LIB_PTHREAD)" -P $(vcs_table) $(src_files)

vcs-clean:
	rm -rf csrc simv*


# Mentor ModelSim
vsim:
	make -e deps CFLAGS="-DMENTOR_MODELSIM"
	vlib work
	vlog $(VSIM_FLAGS) $(src_files)
	vsim -c $(src_module) -pli $(RubyVpiPath)/ruby-vpi.so -do "run -all"

vsim-clean:
	rm -rf work transcript
