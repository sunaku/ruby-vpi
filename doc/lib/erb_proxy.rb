#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

$: << File.basename(__FILE__)
require 'erb_content'

class ErbProxy
  attr_reader :handlers

  def initialize
    @handlers = {}
  end

  # Adds a new handler that can be invoked from a ERB
  # template.  The arguments passed to the handler are:
  #
  # 1. unique identifier for the calling location in the ERB template
  #
  # 2. buffer containing the evaluated results of the ERB template thus far
  #
  # 3. content that was passed to the handler from the ERB template
  #
  # 4. variable number of method arguments passed from the ERB template
  #
  def add_handler aName, &aHandler # :yields: caller, buffer, content, *args
    @handlers[aName] = aHandler

    # XXX: using a string because define_method
    #      does not accept a block until Ruby 1.9
    instance_eval %{
      def #{aName} *args, &block
        if block_given?
          args = ERB.buffer_and_content(&block).concat(args)
        else
          args.unshift '', ''
        end
        @handlers[#{aName.inspect}].call(Kernel.caller.first, *args)
      end
    }
  end
end
