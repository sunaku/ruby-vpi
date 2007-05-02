# ERB templating.
#--
# Copyright 2006-2007 Suraj N. Kurapati
# See the file named LICENSE for details.

require 'erb'

# A version of ERB whose embedding tags behave like those of PHP. That is, only
# <%= ... %> tags produce output, whereas <% ... %> tags do *not* produce any
# output.
class ERB
  alias original_initialize initialize

  def initialize aInput, *aArgs
    # ensure that only <%= ... %> tags generate output
      input = aInput.gsub %r{<%=.*?%>}m do |s|
        if ($' =~ /\r?\n/) == 0
          s << $&
        else
          s
        end
      end

      aArgs[1] = '>'

    original_initialize input, *aArgs
  end
end
