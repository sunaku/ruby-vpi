
# Brings the design under test into a blank state.
def reset!
  reset.high!
  cycle!
  reset.low!
end

# Simulates the design under test for one clock cycle.
def cycle!
  ##
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
  ##

  clock.high!

  ##
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
  ##

  advance_time

  ##
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
  ##

  clock.low!

  ##
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
  ##

  advance_time

  ##
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
  ##
end
