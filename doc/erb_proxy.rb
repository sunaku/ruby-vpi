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

class ErbProxy < ERB
  attr_reader :handlers, :buffer

  def initialize *aErbArgs
    @buffer = ""
    @handlers = {}

    aErbArgs[3] = :@buffer
    super *aErbArgs
  end

  # Add a new handler method that can be called from your ERB template.
  def add_handler aName, &aHandler
    @handlers[aName] = aHandler

    # using a string because define_method does not accept a block until Ruby 1.9
    instance_eval %{
      def #{aName} *args, &block
        @handlers[#{aName.inspect}].call *handler_content(&block).concat(args)
      end
    }
  end

  # Returns an array containing (1) the contents of the ERB buffer thus far and (2) the text that is to be added to the ERB buffer.
  def handler_content
    # backup the buffer because 'yield' is gonna append to it
      buf = @buffer
      @buffer = ""

    text = yield rescue nil

    # restore the backup
      @buffer = buf

    [buf, text]
  end
end
