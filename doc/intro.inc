bq. Ruby-VPI is a "Ruby":http://www.ruby-lang.org interface to "Verilog VPI":http://ieeexplore.ieee.org/xpl/standardstoc.jsp?isnumber=33945. It lets you create complex Verilog test benches easily and wholly in Ruby.


h2(#intro.features). Features

* Supports the _entire_ IEEE Std 1364-2005 VPI standard.

* Works with all "major Verilog simulators":manual.html#setup.reqs available today.

* Enables "agile practices":http://www.agilealliance.org/intro such as
** "test-driven":http://www.testdriven.com development
** "behavior-driven":http://behaviour-driven.org development
** "rapid prototyping":manual.html#usage.tutorial.implement-proto for design exploration

* Eliminates unneccesary work:
** "Specifications":manual.html#usage.tutorial.specification are _readable_, portable, and executable.
** The "automated test generator":manual.html#usage.tools.generate-test helps you accomodate design changes with _minimal_ effort.

* Utilizes the "power and elegance":http://www.ruby-lang.org/en/about/ of Ruby:
** Unlimited length integers
** Regular expressions
** Multi-threading
** System calls and I/O
** "_ad infinium_":http://rubyforge.org

* Gives you the _freedom_ to study, modify, and distribute this software, in accordance with the "GNU General Public License":http://www.gnu.org/copyleft/gpl.html.


h2(#intro.appetizers). Appetizers

Here is a modest sampling to whet your appetite.

* Assign the value 2^2048^ to a register:
  @some_register.intVal = 2 ** 2048@

* Check if all nets in a module are at high impedance:
  @some_module.all_net? { |net| net.z? }@

* Print a register's path, width, and location (file & line number):
  @puts some_register@

* Simulate fifteen clock cycles:
  @15.times { relay_verilog }@

