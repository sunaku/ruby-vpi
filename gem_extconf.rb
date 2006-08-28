## This file is invoked by RubyGems to build the extension. ##

require 'fileutils'

system('rake build clean') &&
FileUtils.touch('Makefile')

exit $?.exitstatus
