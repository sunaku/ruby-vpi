module test;
  reg a;
  initial begin
    #0 $display($time); $ruby_init();
    #10 $display($time); $ruby_callback();
    #10 $display($time); $ruby_callback();
    #10 $display($time); $ruby_callback();
    #10 $display($time); $ruby_callback();
    #10 $display($time); $ruby_callback();
  end
endmodule
