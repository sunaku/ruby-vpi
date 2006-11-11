bq. Ruby-VPI is a "Ruby":http://www.ruby-lang.org interface to "Verilog VPI":http://ieeexplore.ieee.org/xpl/standardstoc.jsp?isnumber=33945. It lets you create complex Verilog test benches easily and wholly in Ruby.


h2(#intro.appetizers). Appetizers

Here are some quick examples to whet your appetite.

* Assign the value 2^2048^ to a register:
  @some_register.intVal = 2 ** 2048@

* Check if all registers in a module are currently at high impedance:
  @some_module.all_reg? { |reg| reg.z? }@

* Simulate until the _alert_ signal becomes 4'b1101:
  @relay_verilog until alert.intVal == 0b1101@


h2(#intro.features). Features

* "Prototype":manual.html#usage.tutorial.implement-proto and verify Verilog designs _quickly_ using "BDD(behavior-driven development)":http://behaviour-driven.org, "TDD(test-driven development)":http://www.testdriven.com, and more.

* "Reuse":manual.html#usage.tutorial.test-proto the _same_ specification to verify both Ruby prototype and Verilog design _without_ having to modifiy any code.

* "Specifications":manual.html#usage.tutorial.specification are executable and human-readable.

* Utilize the "power and elegance":http://www.ruby-lang.org/en/about/ of Ruby:
** Unlimited length integers
** Regular expressions
** Multi-threading
** System calls and I/O
** "_ad infinium_":http://www.ruby-doc.org/whyruby

* Study, modify, and distribute this free software in accordance with the "GNU General Public License":http://www.gnu.org/copyleft/gpl.html.

