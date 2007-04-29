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

# Returns an array containing the current ERB buffer and the content that the
# given block will append to the buffer when it is invoked.
#
# == Example
# Suppose your ERB template invoked a method with some arguments and some
# content in a block. You can pass the block to this method to obtain the
# content contained within the block.
#
## template = ERB.new <<-EOS
## <% wrap_xml "message" do %>
##   i love ruby!
## <% end %>
## EOS
#
# In this case, the ERB template invokes the _wrap_xml_ method to wrap some
# content within a pair of XML tags.
#
## def wrap_xml tag, &block
##   buffer, content = ERB.buffer_and_content(&block)
##   buffer << "<#{tag}>#{content}</#{tag}>"
## end
#
# When we evaluate the template:
## puts template.result(binding)
#
# we see the following output:
## <message>
##   i love ruby!
## </message>
#
def ERB.buffer_and_content
  raise ArgumentError unless block_given?

  # buffer + content
  buffer = yield
  a = buffer.length

  # buffer + content + content
  yield
  b = buffer.length

  # buffer + content
  content = buffer.slice! a..b

  # buffer
  buffer.slice!((-content.length)..-1)

  [buffer, content]
end
