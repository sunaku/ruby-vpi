require 'mkmf'

have_header('pthread.h') &&
have_header('ruby.h') &&

create_makefile('ruby-vpi')
