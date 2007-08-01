# Utilities for Rakefiles.
#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

require 'fileutils'

module FileUtils
  alias old_sh sh

  # An improved sh() that also accepts arrays as arguments.
  def sh *aArgs, &aBlock
    old_sh(*collect_args(aArgs).reject {|i| i.to_s.empty?}, &aBlock)
  end

  # Collects the given arguments into a single, sparse array.
  def collect_args *aArgs
    aArgs.flatten.compact
  end
end
