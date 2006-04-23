require 'mkmf'

have_library 'pthread', 'pthread_create'
create_makefile 'ruby-vpi'
