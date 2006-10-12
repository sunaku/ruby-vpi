## This file is invoked by RubyGems to build the extension.

require 'fileutils'

system('rake build gem_config_inst') &&
FileUtils.touch('Makefile')

exit $?.exitstatus
