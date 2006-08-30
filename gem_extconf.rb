## This file is invoked by RubyGems to build the extension.

require 'fileutils'

system('rake build config_gem_install') &&
FileUtils.touch('Makefile')

exit $?.exitstatus
