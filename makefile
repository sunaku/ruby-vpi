# path to the directory which contains vpi_user.h
VERILOG = /usr/include

# flags used when Ruby was compiled on your system
cflags = `ruby -r mkmf -e 'cflags = $$configure_args["--cflags"]; puts cflags if cflags'`
cflags += -g -DDEBUG $(CFLAGS)

ldflags = `ruby -r mkmf -e 'ldflags = $$configure_args["--ldflags"]; puts ldflags if ldflags'`
ldflags += $(LDFLAGS)


# path to Ruby-VPI source code directory
src_dir = src


all: ruby-vpi

clean: swig-clean ruby-vpi-clean


ruby-vpi: Makefile
	make -f Makefile

ruby-vpi-clean:
	-make -f Makefile distclean


Makefile: swig
	ruby $(src_dir)/extconf.rb --with-cflags="$(cflags)" --with-ldflags="$(ldflags)" --with-verilog-include="$(VERILOG)" $(OPTIONS)


swig: $(src_dir)/swig_wrap.cin

$(src_dir)/swig_wrap.cin:
	sed 's/va_list/int/g' $(src_dir)/vpi_user.h > $(src_dir)/vpi.h
	swig -ruby -o $(src_dir)/swig_wrap.cin $(src_dir)/vpi.i

swig-clean:
	rm -f $(src_dir)/vpi.h $(src_dir)/swig_wrap.cin

