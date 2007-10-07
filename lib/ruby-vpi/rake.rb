# Utilities for Rakefiles.
#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

require 'fileutils'

module FileUtils
  alias old_sh sh

  # An improved sh() that accepts arrays as arguments, omits empty string
  # arguments, and shows users exactly what ARGV is being executed.
  def sh *aArgs, &aBlock
    args = aArgs.flatten.compact.reject {|i| i.to_s.empty?}
    STDERR.puts args.inspect
    old_sh(*args, &aBlock)
  end
end
