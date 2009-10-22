# Boot loader for the Ruby side of the Ruby-VPI cosimulation.
#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

puts ">>> hello from loader!"
p :ZERO => $0
p :FILE => __FILE__

puts ">>> gonna relay"
VPI.do_the_relay
reason = VPI.get_relay_reason
puts ">>> back from relay! #{reason.inspect} woo!!"

# puts ">>> gonna relay AGAIN"
# VPI.do_the_relay
# reason = VPI.get_relay_reason
# puts ">>> back from relay AGAIN! #{reason.inspect} woo!!"

# Transfers control to the simulator, which will return control
# during the given time slot after the given number of time steps.
def relay_verilog aTimeSlot, aNumSteps
  # schedule wake-up callback from verilog
    time            = VPI::S_vpi_time.new
    time.high       = 0
    time.low        = aNumSteps
    time.type       = VPI::VpiSimTime

    value           = VPI::S_vpi_value.new
    value.format    = VPI::VpiSuppressVal

    alarm           = VPI::S_cb_data.new
    alarm.reason    = aTimeSlot
    alarm.cb_rtn    = VPI::RubyVPI_user_resume
    alarm.obj       = nil
    alarm.time      = time
    alarm.value     = value
    alarm.index     = 0
    alarm.user_data = nil

    VPI.vpi_free_object(VPI.vpi_register_cb(alarm))

  # transfer control to verilog
  puts ">>> gonna relay CALLBACK"
  VPI.do_the_relay
  reason = VPI.get_relay_reason
  puts ">>> back from relay CALLBACK! #{reason.inspect} woo!!"
  reason
end

relay_verilog VPI::CbAfterDelay, 1
relay_verilog VPI::CbAfterDelay, 5
relay_verilog VPI::CbAfterDelay, 1

# puts "not letting ruby exit"
# VPI.do_the_relay

puts "This is the END for Ruby!!"

__END__

begin

  # copy Ruby output into simulator's log file
    [STDOUT, STDERR].each do |stream|
      class << stream #:nodoc:
        alias __write__ write

        def write aString
          s = aString.to_s

          VPI.vpi_printf(s)
          return s.length
        end
      end
    end

  # XXX: in the C extension, we use rb_require() to run this
  #      boot loader.  when that finishes, any at_exit handlers
  #      are NOT automatically invoked (since rb_require() does
  #      not internally run ruby_finalize()).  so this is a
  #      workaround to simulate at_exit invocation, which is
  #      used by RSpec and Test::Unit to execute the unit test
  module Kernel
    alias __RubyVPI__orig_at_exit at_exit

    @@__RubyVPI__exit_handlers = []

    def at_exit &aBlock # :nodoc:
      @@__RubyVPI__exit_handlers.unshift aBlock if aBlock
    end

    # runs all fake at_exit handlers
    def __RubyVPI__simulate_exit # :nodoc:
      if defined? @@__RubyVPI__exit_handlers
        @@__RubyVPI__exit_handlers.each do |handler|
          begin
            handler.call
          rescue SystemExit
            # ignore
          end
        end
      end
    end

    module_function :__RubyVPI__simulate_exit
  end

  module RubyVPI
    USE_SIMULATOR = ENV['RUBYVPI_SIMULATOR'].to_sym
    USE_DEBUGGER  = ENV['DEBUGGER'].to_i  == 1
    USE_COVERAGE  = ENV['COVERAGE'].to_i  == 1
    USE_PROTOTYPE = ENV['PROTOTYPE'].to_i == 1
    USE_PROFILER  = ENV['PROFILER'].to_i  == 1
    HAVE_RUBY_19X = RUBY_VERSION =~ /^1\.9\./
    HAVE_RUBY_18X = RUBY_VERSION =~ /^1\.8\./
  end

  require 'rubygems'
  require 'ruby-vpi'
  require 'ruby-vpi/core'

  # set up code coverage analysis
    if RubyVPI::USE_COVERAGE
      require 'ruby-vpi/rcov'

      outFile = "coverage.txt"
      RubyVPI::Coverage.attach do |analysis|
        begin
          File.open(outFile, 'w') do |f|
            STDOUT.flush
            $stdout = f

            analysis.dump_coverage_info [
              Rcov::TextReport.new,
              Rcov::FullTextReport.new(:textmode => :counts),
            ]
          end
        ensure
          $stdout = STDOUT
        end
      end

      RubyVPI::Coverage.start
      RubyVPI.say "coverage analysis is enabled; results stored in #{outFile}"
    end

  # set up the interactive debugger
    if RubyVPI::USE_DEBUGGER
      require 'ruby-debug'

      Debugger.start
      Debugger.post_mortem

      RubyVPI.say 'interactive debugger is enabled'
    end

    # suppress undefined method errors when debugger is not enabled
      unless Kernel.respond_to? :debugger
        Kernel.class_eval do
          # Starts an interactive debugging session.
          def debugger
          end
        end
      end

  # set up the profiler
    if RubyVPI::USE_PROFILER
      require 'ruby-prof'

      outFile = "profile.txt"
      at_exit do
        result = RubyProf.stop
        printer = RubyProf::GraphPrinter.new(result)

        File.open(outFile, 'w') do |out|
          printer.print(out)
        end
      end

      RubyProf.start
      RubyVPI.say "performance analysis is enabled; results stored in #{outFile}"
    end

  # set up the prototyping environment
    if RubyVPI::USE_PROTOTYPE
      VPI.module_eval do
        def vpi_register_cb *args #:nodoc:
          warn "vpi_register_cb: callbacks are ignored when prototype is enabled"
        end
      end

      RubyVPI.say 'prototype is enabled'
    end

  # make VPI functions available globally
    class Object
      include VPI
    end

  RubyVPI::Scheduler.run do
    # load the user-defined test loader
    require ENV['RUBYVPI_TEST_LOADER']

    # simulate at_exit handler invocation
    Kernel.__RubyVPI__simulate_exit

    # restore original at_exit handler
    module Kernel
      alias at_exit __RubyVPI__orig_at_exit
      undef __RubyVPI__simulate_exit
    end
  end

  RubyVPI.detach

rescue Exception => e
  # mimic how Ruby internally prints exceptions
  STDERR.puts "#{e.class}: #{e.message}", e.backtrace.map {|s| "\tfrom #{s}" }
end
