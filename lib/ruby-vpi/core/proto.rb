# Ruby prototypes of verilog designs under test.
#--
# Copyright 2007 Suraj N. Kurapati
# See the file named LICENSE for details.

module RubyVPI::Prototype #:nodoc:
end

module RubyVPI
  module Prototype
    @@protos = []

    def Prototype.attach aProto
      @@protos << aProto
    end

    def Prototype.detach aProto
      @@protos.delete aProto
    end

    def Prototype.simulate_hardware
      @@protos.each do |proto|
        proto.feign!
      end
    end
  end
end
