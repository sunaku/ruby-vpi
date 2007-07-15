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


h2(#intro.reqs). Requirements

The following software is necessary in order to use Ruby-VPI.

p(title). Verilog simulator

Ruby-VPI is known to work with the following simulators. However, you should be able to use it with any Verilog simulator that supports VPI.

* "Synopsys VCS":http://www.synopsys.com/products/simulation/simulation.html
 - any version that supports the <tt>-load</tt> option is acceptable.

* "Mentor Modelsim":http://www.model.com
 - any version that supports the <tt>-pli</tt> option is acceptable.

* "Cadence NC-Sim / NC-Verilog":http://www.cadence.com/products/functional_ver/nc-verilog/
 - any version that supports the <tt>+loadvpi</tt> option is acceptable.

* "GPL Cver":http://www.pragmatic-c.com/gpl-cver/
 - version 2.11a or newer is acceptable.

* "Icarus Verilog":http://www.icarus.com/eda/Verilog/
  - version 0.8 is _mostly_ acceptable -- you *will not* be able to "access child handles through method calls":manual.html#background.org.vpi.util. The reason for this limitation is explained "in the user manual":manual.html#problems.ivl.vpi_handle_by_name.absolute-paths.

p(title). Compilers

* "make":http://en.wikipedia.org/wiki/Make
  - any flavor should be acceptable.

* C compiler
  - the "GNU Compiler Collection (GCC)":http://www.gnu.org/software/gcc/ is preferred, but any C compiler should be acceptable.

* "Ruby":http://www.ruby-lang.org
  - version 1.8 or newer, including header and linkable object files for building extensions, is necessary. You can install Ruby by following "these instructions":http://www.rubygarden.org/faq/section/show/3.

p(title). Libraries

* "POSIX threads (pthreads)":http://en.wikipedia.org/wiki/Pthreads
  - header and linkable object files, and operating system support for this library are necessary.

* "RubyGems":http://rubyforge.org/frs/?group_id=126
  - any recent version should be acceptable. You can install RubyGems by following "these instructions":http://www.rubygems.org/read/chapter/3.


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


h2(#intro.license). License

<%=h File.read('../LICENSE') %>


h2(#intro.related-works). Related works

* "JOVE":http://jove.sourceforge.net is a Java interface to VPI.
* "Teal":http://teal.sourceforge.net is a C++ interface to VPI.
* "ScriptEDA":http://embedded.eecs.berkeley.edu/Alumni/pinhong/scriptEDA/ is a Perl, Python, and Tcl interface to VPI.
* "RHDL":http://rhdl.rubyforge.org is a hardware description and verification language based on Ruby.
* "MyHDL":http://myhdl.jandecaluwe.com is a hardware description and verification language based on Python, which features conversion to Verilog and co-simulation.


h3(#intro.related-works.pli). Ye olde PLI

The following projects utilize the archaic *tf* and *acc* PLI interfaces, which have been officially deprecated in IEEE Std 1364-2005.

* "ScriptSim":http://www.nelsim.com is a Perl, Python, and Tcl/Tk interface to PLI.
* "Verilog::Pli":http://www.veripool.com/verilog-pli.html is a Perl interface to PLI.
* "JPLI":http://www.time-rover.com/jpli/ is a proprietary Java interface to PLI.
