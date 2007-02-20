Ruby-VPI is a "Ruby":http://www.ruby-lang.org interface to "IEEE 1364-2005 Verilog VPI":http://ieeexplore.ieee.org/xpl/standardstoc.jsp?isnumber=33945. It lets you create complex Verilog test benches easily and wholly in Ruby.


p(title). Documentation

* "Tutorial":manual.html#usage.tutorial
  - learn how to use Ruby-VPI quickly.
* "Manual":manual.html
  - complete documentation for users. _Start here!_
* "Reference":../ref/
  - API documentation for Ruby libraries and C extension.


p(title). Records

* <a type="application/rss+xml" href="<%= RSS_URL %>">!images/mozilla/feed-icon.png(RSS feed icon)! RSS feed</a>
  - keep track of new releases at your leisure.
* "Release history":history.html
  - record of all release notes.
* "Memorandum":memo.html
  - pending tasks for future releases.


p(title). Facilities

* "Project portal":http://rubyforge.org/projects/ruby-vpi
  - hosted generously by "RubyForge":http://rubyforge.org.
* "Source code":http://ruby-vpi.rubyforge.org/src/ruby-vpi
  - browse online or obtain through "Darcs":http://abridgegame.org/darcs/.
* "Downloads":http://rubyforge.org/frs/?group_id=1339
  - obtain release packages.
* "Bugs":http://rubyforge.org/tracker/?group_id=1339
  - report defects in the software.
* "Patches":http://rubyforge.org/tracker/?group_id=1339
  - submit patches to source code.
* "Requests":http://rubyforge.org/tracker/?group_id=1339
  - request new features or get support.
* "Forums":http://rubyforge.org/forum/?group_id=1339
  - discuss things and ask questions.


p(title). Outreach

* "News":http://ruby-vpi.rubyforge.org/news
  - see what's cooking for the next release.
* "Talks":http://ruby-vpi.rubyforge.org/talks
  - materials from presentations and seminars.


h2(#intro.features). Prominent features

h3. Portable

* Supports the _entire_ "IEEE Std 1364-2005":http://ieeexplore.ieee.org/xpl/standardstoc.jsp?isnumber=33945 VPI standard.

* Works with all "major Verilog simulators":manual.html#setup.reqs available today.
** Compiled _just once_ during "installation":manual.html#setup.installation and used forever!

h3. Agile

* Enables "agile practices":http://agilemanifesto.org/ such as
** "test-driven":http://www.testdriven.com development
** "behavior-driven":http://behaviour-driven.org development
** "rapid prototyping":manual.html#usage.tutorial.implement-proto for design exploration

* Eliminates unneccesary work:
** "Specifications":manual.html#usage.tutorial.specification are readable, portable, and _executable_.
** The "automated test generator":manual.html#usage.tools.generate-test helps you accomodate design changes with _minimal_ effort.
** There is absolutely _no compiling_!

h3. Powerful

* Inherits the "power and elegance":http://www.ruby-lang.org/en/about/ of Ruby:
** Unlimited length integers
** Regular expressions
** Multi-threading
** System calls and I/O
** "_ad infinitum_":http://rubyforge.org

* Uses "ruby-debug":http://rubyforge.org/projects/ruby-debug/ for "interactive debugging":manual.html#usage.debugger.
* Uses "rcov":http://eigenclass.org/hiki.rb?rcov for test "coverage analysis and report generation":manual.html#usage.test-runner.env-vars.

h3. Free

* Gives you the _freedom_ to study, modify, and distribute this software, in accordance with the "GNU General Public License":http://www.gnu.org/copyleft/gpl.html.


h2(#intro.applications). Applications

Here is a modest sampling of tasks that Ruby-VPI can be used to perform.

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

Here is a modest sampling of code to whet your appetite.

* Assign the value 2^2048^ to a register:

bq. @some_register.intVal = 2 ** 2048@

* Check if all nets in a module are at high impedance:

bq. @some_module.all_net? { |net| net.z? }@

* See a register's path, width, and location (file & line number):

bq. @puts some_register@

* Simulate fifteen clock cycles:

bq. @15.times { simulate }@
