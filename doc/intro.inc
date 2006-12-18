bq. Ruby-VPI is a "Ruby":http://www.ruby-lang.org interface to "Verilog VPI":http://ieeexplore.ieee.org/xpl/standardstoc.jsp?isnumber=33945. It lets you create complex Verilog test benches easily and wholly in Ruby.


h2(#intro.features). Features

* Supports the _entire_ "IEEE Std 1364-2005"::http://ieeexplore.ieee.org/xpl/standardstoc.jsp?isnumber=33945 VPI standard.

* Works with all "major Verilog simulators":manual.html#setup.reqs available today.
** Compile _once_ (during "installation":manual.html#setup.installation) and use forever!

* Enables "agile practices":http://agilemanifesto.org/ such as
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
** "_ad infinitum_":http://rubyforge.org

* Gives you the _freedom_ to study, modify, and distribute this software, in accordance with the "GNU General Public License":http://www.gnu.org/copyleft/gpl.html.


h3(#intro.applications). Applications

Here is a modest sampling of tasks, paraphrased from "Pin Hong":http://embedded.eecs.berkeley.edu/Alumni/pinhong/scriptEDA/, that Ruby-VPI can be used to perform.

* Writing hardware models in Ruby
* Dumping/processing netlist data from Verilog database
* Dumping/processing simulation data
* Feeding dynamic simulation stimuli
* Back-annotating delay information
* Interactive logic simulation
* Building a distributed simulation


h3(#intro.appetizers). Appetizers

Here is a modest sampling of code to whet your appetite.

* Assign the value 2^2048^ to a register:

bq. @some_register.intVal = 2 ** 2048@

* Check if all nets in a module are at high impedance:

bq. @some_module.all_net? { |net| net.z? }@

* See a register's path, width, and location (file & line number):

bq. @puts some_register@

* Simulate fifteen clock cycles:

bq. @15.times { relay_verilog }@

