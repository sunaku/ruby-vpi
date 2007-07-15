#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

require 'erb_content'

class ErbProxy
  attr_reader :handlers

  def initialize
    @handlers = {}
  end

  # Adds a new handler that can be invoked from a ERB
  # template.  The arguments passed to the handler are:
  #
  # 1. buffer containing the evaluated results of the ERB template thus far
  #
  # 2. content that was passed to the handler from the ERB template
  #
  # 3. variable number of method arguments passed from the ERB template
  #
  def add_handler aName, &aHandler # :yields: buffer, content, *args
    @handlers[aName] = aHandler

    # XXX: define_method does not accept a block until Ruby 1.9
    instance_eval %{
      def #{aName} *args, &block
        raise ArgumentError unless block_given?

        args.unshift(*ERB.buffer_and_content(&block))
        @handlers[#{aName.inspect}].call(*args)
      end
    }
  end

  # Evaluates the given ERB template.  Used to
  # dynamically include one template within another.
  def import aErbFile
    ERB.new(File.read(aErbFile)).result
  end
end
