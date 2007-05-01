Ruby-VPI is a platform for unit testing, rapid prototyping, and systems integration of Verilog modules through the "Ruby programming language":http://www.ruby-lang.org. It lets you:

* Access the _entire_ "IEEE 1364-2005 Verilog VPI":http://ieeexplore.ieee.org/xpl/standardstoc.jsp?isnumber=33945 interface from Ruby.
* Create complex Verilog test benches easily and wholly in Ruby.
* Apply agile software development practices to develop hardware.
* Perform "specification-driven functional verification":http://ruby-vpi.rubyforge.org/papers/masters_thesis.html ("PDF version":http://ruby-vpi.rubyforge.org/papers/masters_thesis.pdf).

Ruby-VPI is "open source software":http://en.wikipedia.org/wiki/Open_source_software released under "this license":#intro.license.


<div id="resources">

h2. Resources

p(title). Records

<a type="application/rss+xml" href="<%= RSS_URL %>"><img src="images/feed-icon-28x28.png" alt="RSS feed for release notifications" style="float: right"/></a>

* "What's new?":history.html
  - a record of all release notes.
* "Plans":memo.html
  - pending tasks for future releases.
* "Talks":http://ruby-vpi.rubyforge.org/talks/
  - materials from presentations and seminars.
* "Papers":http://ruby-vpi.rubyforge.org/papers/
  - research publications.

p(title). Documentation

* "Tutorial":manual.html#usage.tutorial
  - learn how to use Ruby-VPI quickly.
* "Manual":manual.html
  - complete documentation for users. _Start here!_
* "Reference":../ref/
  - API documentation for Ruby libraries and C extension.

p(title). Facilities

* "Downloads":http://rubyforge.org/frs/?group_id=1339
  - obtain release packages.
* "Source code":http://ruby-vpi.rubyforge.org/src/ruby-vpi
  - browse online or obtain with "Darcs":http://darcs.net.
* "Forums":http://rubyforge.org/forum/?group_id=1339
  - discuss things and ask questions.
* "Bugs":http://rubyforge.org/tracker/?group_id=1339
  - report defects in the software.
* "Patches":http://rubyforge.org/tracker/?group_id=1339
  - submit patches to source code.
* "Requests":http://rubyforge.org/tracker/?group_id=1339
  - request new features or get support.
* "Project portal":http://rubyforge.org/projects/ruby-vpi
  - hosted generously by "RubyForge":http://rubyforge.org.


</div>


h2(#intro.features). Features

p(title). Portable

* Supports the _entire_ "IEEE 1364-2005 Verilog VPI":http://ieeexplore.ieee.org/xpl/standardstoc.jsp?isnumber=33945 standard.
* Works with all "major Verilog simulators":#intro.reqs available today.
* Compiled _just once_ during "installation":manual.html#setup.installation and used forever!

p(title). Agile

* Enables "agile practices":http://agilemanifesto.org/ such as
** "test-driven":http://www.testdriven.com development
** "behavior-driven":http://behaviour-driven.org development
** "rapid prototyping":manual.html#usage.tutorial.implement-proto for design exploration

* Eliminates unneccesary work:
** "Specifications":manual.html#usage.tutorial.specification are readable, portable, and _executable_.
** The "automated test generator":manual.html#usage.tools.generate-test helps you accomodate design changes with _minimal_ effort.
** There is absolutely _no compiling_!

p(title). Powerful

* Inherits the "power and elegance":http://www.ruby-lang.org/en/about/ of Ruby:
** Unlimited length integers
** Regular expressions
** Multi-threading
** System calls and I/O
** "_ad infinitum_":http://rubyforge.org

* Uses "ruby-debug":http://rubyforge.org/projects/ruby-debug/ for "interactive debugging":manual.html#usage.debugger.
* Uses "rcov":http://eigenclass.org/hiki.rb?rcov for test "coverage analysis and report generation":manual.html#usage.test-runner.env-vars.


* Gives you the _freedom_ to study, modify, and distribute this software, in accordance with the "GNU General Public License":http://www.gnu.org/copyleft/gpl.html.


h2(#intro.applications). Applications

Examples of tasks that can be performed with Ruby-VPI are:

* From the second edition of "_The Verilog PLI Handbook_":http://www.sutherland-hdl.com/publications.html:
** C language bus-functional models
** Reading test vector files
** Delay calculation
** Custom output displays
** Co-simulation
** Design debug utilities
** Simulation analysis

* Adapted from "Pin Hong's":http://embedded.eecs.berkeley.edu/Alumni/pinhong/scriptEDA/ observations:
** Writing hardware models in Ruby
** Dumping or processing netlist data from Verilog database
** Dumping or processing simulation data
** Feeding dynamic simulation stimuli
** Back-annotating delay information
** Interactive logic simulation
** Building a distributed simulation


h2(#intro.appetizers). Appetizers

Here is a tiny sampling of code to whet your appetite. See "the tutorial":manual.html#usage.tutorial for more samples.

* Assign the value 2^2048^ to a register:

bq. @some_register.intVal = 2 ** 2048@

* Check if all nets in a module are at high impedance:

bq. @some_module.all_net? { |net| net.z? }@

* See a register's path, width, and location (file & line number):

bq. @puts some_register@

* Simulate fifteen clock cycles:

bq. @15.times { simulate }@
