# flags used when Ruby was compiled on your system
cflags = `ruby -r rbconfig -e 'puts Config::CONFIG["CFLAGS"] || ""'` -g -DDEBUG $(CFLAGS)

ldflags = `ruby -r rbconfig -e 'puts Config::CONFIG["LDFLAGS"] || ""'`


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
	ruby -pe '$$_.gsub! /va_list/, "int"' $(src_dir)/vpi_user.h > $(src_dir)/swig_vpi.h	# avoid problems with SWIG-generated wrapper for VPI vprintf functions which use va_list
	swig -ruby -o $(src_dir)/swig_wrap.cin $(src_dir)/swig_vpi.i

swig-clean:
	rm -f $(src_dir)/swig_vpi.h $(src_dir)/swig_wrap.cin


doc: README HISTORY $(src_dir)/vpi_util.rb $(src_dir)/html
	rdoc1.8 -t "Ruby-VPI :: Ruby interface to Verilog VPI" $^

$(src_dir)/html:
	cd $(src_dir) && doxygen

doc-clean:
	rm -rf doc $(src_dir)/html

