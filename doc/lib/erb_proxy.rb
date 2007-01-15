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

require 'erb_content'

class ErbProxy
  attr_reader :handlers

  def initialize
    @handlers = {}
  end

  # Adds a new handler that can be invoked from a ERB template.
  # The arguments passed to the handler are:
  # 1. buffer containing the evaluated results of the ERB template (so far; at this point in time)
  # 2. content that was passed to the handler from the ERB template
  # 3. variable number of method arguments passed from the ERB template
  def add_handler aName, &aHandler # :yields: buffer, content, *args
    @handlers[aName] = aHandler

    # using a string because define_method does not accept a block until Ruby 1.9
    instance_eval %{
      def #{aName} *args, &block
        raise ArgumentError unless block_given?

        args.unshift(*ERB.buffer_and_content(&block))
        @handlers[#{aName.inspect}].call(*args)
      end
    }
  end

  # Evaluates the given ERB template. Used to dynamically include one template within another.
  def import aErbFile
    ERB.new(File.read(aErbFile)).result
  end
end
