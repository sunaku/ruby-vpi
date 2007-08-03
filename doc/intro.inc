Ruby-VPI is a platform for unit testing, rapid prototyping, and systems integration of Verilog modules through the "Ruby programming language":http://www.ruby-lang.org. It lets you:

* Access the _entire_ "IEEE 1364-2005 Verilog VPI":http://ieeexplore.ieee.org/xpl/standardstoc.jsp?isnumber=33945 interface from Ruby.
* Create complex Verilog test benches easily and wholly in Ruby.
* Apply agile software development practices to develop hardware.
* Perform "specification-driven functional verification":http://ruby-vpi.rubyforge.org/papers/masters_thesis.html ("PDF version":http://ruby-vpi.rubyforge.org/papers/masters_thesis.pdf).

Ruby-VPI is "open source software":http://en.wikipedia.org/wiki/Open_source_software released under "this license":#intro.license.


<% section "Resources", "resources" do %>
  <% paragraph "Records" do %>
    * "What's new":history.html#<%= version.to_html_anchor %>
      - release notes for version <%= version %>.
    ** "History":history.html
      - a record of all release notes.
    ** <a type="application/rss+xml" href="<%= RSS_URL %>"><img src="images/feed-icon-28x28.png" alt="RSS feed for release announcements" style="float: right"/></a> "RSS feed":<%= RSS_URL %>
      - keep track of new releases at your leisure.
    * "Plans":memo.html
      - pending tasks for future releases.
    * "Talks":http://ruby-vpi.rubyforge.org/talks/
      - materials from presentations and seminars.
    * "Papers":http://ruby-vpi.rubyforge.org/papers/
      - research publications.
  <% end %>

  <% paragraph "Documentation" do %>
    * "Motivation":http://ruby-vpi.rubyforge.org/papers/masters_thesis.html#tth_sEc5.2
      - why was Ruby-VPI developed?
    * "User manual":manual.html
      - complete documentation for users.
    ** "Tutorial":manual.html#usage.tutorial
      - learn how to use Ruby-VPI quickly.
    * "Reference":../ref/
      - API documentation for Ruby libraries and C extension.
  <% end %>

  <% paragraph "Facilities" do %>
    * "Downloads":<%= downloadURL %>
      - obtain release packages
    * "Source code":<%= codeURL %>
      - browse online or obtain with "Darcs":http://darcs.net.
    * "Forums":<%= forumURL %>
      - discuss things and ask questions.
    * "Mailing list":<%= mailListURL %>
      - discuss things and ask questions.
    * "Bugs":<%= trackerURL %>
      - report defects in the software.
    * "Patches":<%= trackerURL %>
      - submit patches to source code.
    * "Requests":<%= trackerURL %>
      - request new features or get support.
    * "Project portal":<%= portalURL %>
      - hosted generously by "RubyForge":http://rubyforge.org.
  <% end %>
<% end %>


<% section "Features", "intro.features" do %>
  <% paragraph "Portable" do %>
    * Supports the _entire_ "IEEE 1364-2005 Verilog VPI":http://ieeexplore.ieee.org/xpl/standardstoc.jsp?isnumber=33945 standard.
    * Works with all <%= xref "intro.reqs", "major Verilog simulators" %> available today.
    * Compiled _just once_ during "installation":manual.html#setup.inst and used forever!
  <% end %>

  <% paragraph "Agile" do %>
    * Enables "agile practices":http://agilemanifesto.org/ such as
    ** "test-driven":http://www.testdriven.com development
    ** "behavior-driven":http://behaviour-driven.org development
    ** "rapid prototyping":manual.html#usage.tutorial.implement-proto for design exploration

    * Eliminates unneccesary work:
    ** "Specifications":manual.html#usage.tutorial.specification are readable, portable, and _executable_.
    ** The "automated test generator":manual.html#usage.tools.generate helps you accomodate design changes with _minimal_ effort.
    ** There is absolutely _no compiling_!
  <% end %>

  <% paragraph "Powerful" do %>
    * Inherits the "power and elegance":http://www.ruby-lang.org/en/about/ of Ruby:
    ** Unlimited length integers
    ** Regular expressions
    ** Multi-threading
    ** System calls and I/O
    ** "_ad infinitum_":http://rubyforge.org

    * Uses "ruby-debug":http://rubyforge.org/projects/ruby-debug/ for "interactive debugging":manual.html#usage.debugger.
    * Uses "rcov":http://eigenclass.org/hiki.rb?rcov for test "coverage analysis and report generation":manual.html#usage.test-runner.env-vars.
  <% end %>
<% end %>


<% section "Requirements", "intro.reqs" do %>
  The following software is necessary in order to use Ruby-VPI.

  <% paragraph "Verilog simulator" do %>
    Ruby-VPI is known to work with the following simulators. However, you should be able to use it with any Verilog simulator that supports VPI.

    * "Synopsys VCS":http://www.synopsys.com/products/simulation/simulation.html
     - any version that supports the <tt>-load</tt> option is acceptable.
    * "Mentor Modelsim":http://www.model.com
     - any version that supports the <tt>-pli</tt> option is acceptable.
    * "Cadence NC-Sim":http://www.cadence.com/products/functional_ver/nc-verilog/
     - any version that supports the <tt>+loadvpi</tt> option is _mostly_ acceptable because you *will not* be able to "force values onto wires":manual.html#problem.ncsim.vpiForceFlag.
    * "GPL Cver":http://www.pragmatic-c.com/gpl-cver/
     - version 2.11a or newer is acceptable.
    * "Icarus Verilog":http://www.geda.seul.org/tools/icarus/index.html
      - version 0.8 is _mostly_ acceptable because you *will not* be able to "access child handles through method calls":manual.html#Accessing_a_handle_s_relatives. The reason for this limitation is explained "in the user manual":manual.html#problems.ivl.vpi_handle_by_name.absolute-paths.
  <% end %>

  <% paragraph "Compilers" do %>
    * "make":http://en.wikipedia.org/wiki/Make
      - any flavor should be acceptable.
    * C compiler
      - the "GNU Compiler Collection (GCC)":http://www.gnu.org/software/gcc/ is preferred, but any C compiler should be acceptable.
    * "SWIG":http://www.swig.org/download.html
      - version 1.3.29 or newer is necessary.
    * "Ruby":http://www.ruby-lang.org/en/downloads/
      - version 1.8 or newer, including header and linkable object files for building extensions, is necessary. You can install Ruby by following "these instructions":http://www.ruby-lang.org/en/downloads/.
  <% end %>

  <% paragraph "Libraries" do %>
    * "POSIX threads (pthreads)":http://en.wikipedia.org/wiki/Pthreads
      - header and linkable object files, and operating system support for this library are necessary.
    * "RubyGems":http://rubyforge.org/frs/?group_id=126
      - any recent version should be acceptable. You can install RubyGems by following "these instructions":http://www.rubygems.org/read/chapter/3.
  <% end %>
<% end %>


<% section "Applications", "intro.applications" do %>
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
<% end %>


<% section "Appetizers", "intro.appetizers" do %>
  Here is a tiny sampling of code to whet your appetite. See "the tutorial":manual.html#usage.tutorial for more samples.

  * Assign the value 2^2048^ to a register:

  bq. @your_register.intVal = 2 ** 2048@

  * Check if all nets in a module are at high impedance:

  bq. @your_module.all_net? { |net| net.z? }@

  * See a register's path, width, and location (file & line number):

  bq. @puts your_register@

  * Access the first five elements in a memory:

  bq. @your_memory.memoryWord_a[0..4]@

  * Clear a memory by filling it with zeroes:

  bq. @your_memory.each_memoryWord {|w| w.intVal = 0}@
<% end %>


<% section "License", "intro.license" do %>
  <%= h(File.read('../LICENSE')).gsub(/^Copyright.*$/, '\&<br/>') %>
<% end %>


<% section "Related works", "intro.related-works" do %>
  * "JOVE":http://jove.sourceforge.net is a Java interface to VPI.
  * "Teal":http://teal.sourceforge.net is a C++ interface to VPI.
  * "ScriptEDA":http://embedded.eecs.berkeley.edu/Alumni/pinhong/scriptEDA/ is a Perl, Python, and Tcl interface to VPI.
  * "RHDL":http://rhdl.rubyforge.org is a hardware description and verification language based on Ruby.
  * "MyHDL":http://myhdl.jandecaluwe.com is a hardware description and verification language based on Python, which features conversion to Verilog and co-simulation.

  <% section "Ye olde PLI", "intro.related-works.pli" do %>
    The following projects utilize the archaic *tf* and *acc* PLI interfaces, which have been officially deprecated in IEEE Std 1364-2005.

    * "ScriptSim":http://www.nelsim.com is a Perl, Python, and Tcl/Tk interface to PLI.
    * "Verilog::Pli":http://www.veripool.com/verilog-pli.html is a Perl interface to PLI.
  <% end %>
<% end %>
