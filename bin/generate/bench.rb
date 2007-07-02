# This file is the Ruby side of the bench.

require 'rubygems'
require 'ruby-vpi'

RubyVpi.init_bench(:<%= aOutputInfo.designClassName %>, :<%= aOutputInfo.specFormat %>) do
  # This block of code is executed whenever the "simulate" method
  # is invoked by the specification.  The purpose of this block
  # of code is to simulate the design under test by (typically)
  # toggling the clock signal, as demonstrated below.

  clock    = <%= aOutputInfo.designClassName %>.<%= aModuleInfo.ports.first.name %>
  numSteps = 1

  ##############################################################################
  # We are currently at the position indicated by the exclamation marks (!):
  #
  #          !
  #          !
  #          !    ____________________                        _________________
  #          !   /                    \                      /
  #          !  /                      \                    /
  # _________!_/                        \__________________/
  #          !
  #          !
  #
  ##############################################################################

  clock.intVal = 1

  ##############################################################################
  # After setting the clock signal to high, we are here:
  #
  #                !
  #                !
  #               _!__________________                        _________________
  #              / !                  \                      /
  #             /  !                   \                    /
  # ___________/   !                    \__________________/
  #                !
  #                !
  #
  ##############################################################################

  advance_time(numSteps)

  ##############################################################################
  # After advancing the time, we are here:
  #
  #                                 !
  #                                 !
  #               __________________!_                        _________________
  #              /                  ! \                      /
  #             /                   !  \                    /
  # ___________/                    !   \__________________/
  #                                 !
  #                                 !
  #
  ##############################################################################

  clock.intVal = 0

  ##############################################################################
  # After setting the clock signal to low, we are here:
  #
  #                                       !
  #                                       !
  #               ____________________    !                   _________________
  #              /                    \   !                  /
  #             /                      \  !                 /
  # ___________/                        \_!________________/
  #                                       !
  #                                       !
  #
  ##############################################################################

  advance_time(numSteps)

  ##############################################################################
  # After advancing the time, we are here:
  #
  #                                                      !
  #                                                      !
  #               ____________________                   !    _________________
  #              /                    \                  !   /
  #             /                      \                 !  /
  # ___________/                        \________________!_/
  #                                                      !
  #                                                      !
  #
  ##############################################################################

  # This process repeats when the "simulate" method is invoked again.

end
