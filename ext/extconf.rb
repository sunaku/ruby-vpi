require 'mkmf'
require 'rbconfig'

have_library('pthread', 'pthread_create') &&
have_library(Config::CONFIG['RUBY_SO_NAME'] || 'ruby', 'ruby_init') &&

create_makefile('ruby-vpi')
