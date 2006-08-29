=begin
  Copyright 2006 Suraj N. Kurapati

  This file is part of Ruby-VPI.

  Ruby-VPI is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  Ruby-VPI is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Ruby-VPI; if not, write to the Free Software Foundation,
  Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
=end

require 'erb'

# A version of ERB whose embedding tags behave like those of PHP. That is, only <%= ... %> tags produce output, whereas <% ... %> tags do *not* produce any output.
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
