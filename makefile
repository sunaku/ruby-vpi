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
	ruby $(src_dir)/extconf.rb --with-cflags="$(cflags)" --with-ldflags="$(ldflags)" $(OPTIONS)


swig: $(src_dir)/swig_wrap.cin

$(src_dir)/swig_wrap.cin:
	ruby -pe '$$_.gsub! /va_list/, "int"' $(src_dir)/vpi_user.h > $(src_dir)/vpi.h	# avoid problems with SWIG-generated wrapper for VPI vprintf functions which use va_list
	swig -ruby -o $(src_dir)/swig_wrap.cin $(src_dir)/vpi.i

swig-clean:
	rm -f $(src_dir)/vpi.h $(src_dir)/swig_wrap.cin

