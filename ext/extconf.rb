require 'mkmf'

# check for POSIX threads library
  hasPthread = have_library('pthread', 'pthread_create')

# check for ruby library
  require 'rbconfig'

  rubyLibArgs = Config::CONFIG.values.grep(/^-lruby/)

  rubyLibNames = rubyLibArgs.map {|a| a.sub /^-l/, ''}
  rubyLibNames.unshift 'ruby' # try most common name first
  rubyLibNames.uniq!

  hasRuby = rubyLibNames.inject(false) do |verdict, name|
    verdict ||= have_library(name, 'ruby_init')
  end

hasPthread && hasRuby && create_makefile('ruby-vpi')
