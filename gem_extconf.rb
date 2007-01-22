## This file is invoked by RubyGems to build the extension.

require 'fileutils'

system('rake build gem_config_inst') &&

# create dummy makefile to appease RubyGems
  File.open('Makefile', 'w') do |f|
    f << %w[all install clean].map {|a| "#{a}:\n"}
  end

exit $?.exitstatus
