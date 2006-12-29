# This file is the Ruby side of the bench.

require 'rubygems'
require 'ruby-vpi'

RubyVpi.init_bench :Hw5_unit, :xUnit do
  ##
  # This block is executed whenever Vpi::simulate is invoked.
  #
  # It simulates the design under test by (typically) toggling
  # the clock signal, as demonstrated below.
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

  Hw5_unit.clk.intVal = 1

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

  Hw5_unit.clk.intVal = 0

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
