#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

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
