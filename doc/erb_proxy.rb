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

  # Adds a new handler that can be invoked from a ERB template.
  # The arguments passed to the handler are:
  # 1. buffer containing, so far, the evaluated results of the ERB template
  # 2. content that was passed to the handler from the ERB template
  # 3. variable number of method arguments passed from the ERB template
  def add_handler aName, &aHandler
    @handlers[aName] = aHandler

    # using a string because define_method does not accept a block until Ruby 1.9
    instance_eval %{
      def #{aName} *args, &block
        args.unshift @buffer, handler_content(&block)
        @handlers[#{aName.inspect}].call *args
      end
    }
  end

  # Returns the content passed to a handler from an ERB template.
  def handler_content
    if block_given?
      limit = @buffer.length
      yield # this will append stuff to the buffer
      @buffer.slice! limit..-1
    end
  end
end
