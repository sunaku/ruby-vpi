# This file is the Ruby side of the bench.

require 'rubygems'
require 'ruby-vpi'

RubyVpi.init_bench :Counter, :xUnit do
  ##
  # This block is executed whenever Vpi::simulate is invoked.
  #
  # It simulates the design under test. This is typically done
  # by toggling the clock signal, as demonstrated below.
  ##

  ##
  # We are currently here (marked by the ! signs):
  #
  #    !
  #    !
  #    ! ____      ____      ____      ____
  # ___!/    \____/    \____/    \____/    \
  #    !
  #    !
  #
  ##

  Counter.clock.intVal = 1

  ##
  # After setting the clock signal to high, we are here:
  #
  #      !
  #      !
  #      !____      ____      ____      ____
  # ____/!    \____/    \____/    \____/    \
  #      !
  #      !
  #
  ##

  advance_time

  ##
  # After advancing the time, we are here:
  #
  #          !
  #          !
  #      ____!      ____      ____      ____
  # ____/    !\____/    \____/    \____/    \
  #          !
  #          !
  #
  ##

  Counter.clock.intVal = 0

  ##
  # After setting the clock signal to low, we are here:
  #
  #           !
  #           !
  #      ____ !     ____      ____      ____
  # ____/    \!____/    \____/    \____/    \
  #           !
  #           !
  #
  ##

  advance_time

  ##
  # After advancing the time, we are here:
  #
  #
  #               !
  #               !
  #      ____     ! ____      ____      ____
  # ____/    \____!/    \____/    \____/    \
  #               !
  #               !
  #
  ##

  ##
  # This process repeats when Vpi::simulate is invoked again.
  ##
end
