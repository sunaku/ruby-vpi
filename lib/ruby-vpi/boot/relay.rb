# Defines methods for transferring control between Ruby and Verilog.
#--
# Copyright 2008 Suraj N. Kurapati
# See the file named LICENSE for details.

begin
  module RubyVPI
    require 'thread'

    @@userRun = Queue.new
    @@hostRun = Queue.new

    # Allows the simulator to resume this Ruby code.
    def resume aCallback
      @@userRun.enq aCallback
      attach
    end

    module_function :resume

    # Pauses this Ruby code and waits for the simulator to resume it.
    def pause
      detach
      @@userRun.deq
    end

    module_function :pause

    # Unblocks the simulator, which is waiting for this Ruby code to pause.
    def detach
      @@hostRun.enq nil
    end

    module_function :detach

    # Allows the simulator to wait for this Ruby code to pause.
    def attach
      @@hostRun.deq
    end

    module_function :attach
  end

rescue Exception => e
  # mimic how Ruby internally prints exceptions
  STDERR.puts "#{e.class}: #{e.message}", e.backtrace.map {|s| "\tfrom #{s}" }
end
