cflags = `ruby -r mkmf -e 'cflags = $$configure_args["--cflags"]; puts cflags if cflags'` # the cflags with which Ruby was compiled on your system
cflags += -g -DDEBUG $(CFLAGS)


all: ruby-vpi

clean: ruby-vpi-clean


ruby-vpi: Makefile
	make -f Makefile

Makefile:
	ruby src/extconf.rb --with-cflags="$(cflags)" --with-verilog-dir="$(VERILOG)" $(OPTIONS)

ruby-vpi-clean:
	-make -f Makefile clean
	rm -f Makefile mkmf.log
