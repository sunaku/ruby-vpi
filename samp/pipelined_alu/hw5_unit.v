/*
  Copyright 2006 Suraj N. Kurapati
  See the file named LICENSE for details.
*/

module hw5_unit(
    input clk
  , input reset

  // inputs
  , input [DATABITS-1:0] in_databits
  , input [WIDTH-1:0] a
  , input [WIDTH-1:0] b
  , input [1:0] in_op

  // outputs
  , output reg [WIDTH-1:0] res
  , output reg [DATABITS-1:0] out_databits
  , output reg [1:0] out_op
);

  parameter
    WIDTH    = 32,
    DATABITS = 7,
    OP_NOP   = 0,
    OP_ADD   = 1,
    OP_SUB   = 2,
    OP_MULT  = 3;

  /* PHASE 0: perform the ALU operations */

  // operation ID
    reg [DATABITS-1:0] in_databits_phase0;
    reg [1:0] in_op_phase0;

    always @(*) begin
      in_databits_phase0	= in_databits;
      in_op_phase0 = in_op;
    end

  // addition
    reg [WIDTH-1:0] add_result_phase0;

    always @(*) begin
      add_result_phase0 = a + b;
    end

  // subtraction
    reg [WIDTH-1:0] sub_result_phase0;

    always @(*) begin
      sub_result_phase0 = a - b;
    end

  // multiplication
    reg [WIDTH-1:0] mul_result_phase0;

    always @(*) begin
      mul_result_phase0 = a * b;
    end


  // always @(posedge clk) begin
  // 	$display("in_databits_phase0 => %d", in_databits_phase0);
  // 	$display("in_op_phase0 => %d", in_op_phase0);
  // 	$display("add_result_phase0 => %d", add_result_phase0);
  // 	$display("sub_result_phase0 => %d", sub_result_phase0);
  // 	$display("mul_result_phase0 => %d", mul_result_phase0);
  // end


  /* PHASE 1: delay the ALU results */

    reg [DATABITS-1:0] in_databits_phase1;
    reg [1:0] in_op_phase1;

    reg [WIDTH-1:0] add_result_phase1;
    reg [WIDTH-1:0] sub_result_phase1;
    reg [WIDTH-1:0] mul_result_phase1;

    always @(posedge clk) begin
      in_databits_phase1 <= in_databits_phase0;
      in_op_phase1 <= in_op_phase0;

      add_result_phase1 <= add_result_phase0;
      sub_result_phase1 <= sub_result_phase0;
      mul_result_phase1 <= mul_result_phase0;
    end

    // always @(posedge clk) begin
    // 	$display("in_databits_phase1 => %d", in_databits_phase1);
    // 	$display("in_op_phase1 => %d", in_op_phase1);
    // 	$display("add_result_phase1 => %d", add_result_phase1);
    // 	$display("sub_result_phase1 => %d", sub_result_phase1);
    // 	$display("mul_result_phase1 => %d", mul_result_phase1);
    // end


  /* PHASE 2: delay the ALU results */

    reg [DATABITS-1:0] in_databits_phase2;
    reg [1:0] in_op_phase2;

    reg [WIDTH-1:0] add_result_phase2;
    reg [WIDTH-1:0] sub_result_phase2;
    reg [WIDTH-1:0] mul_result_phase2;

    always @(posedge clk) begin
      in_databits_phase2 <= in_databits_phase1;
      in_op_phase2 <= in_op_phase1;

      add_result_phase2 <= add_result_phase1;
      sub_result_phase2 <= sub_result_phase1;
      mul_result_phase2 <= mul_result_phase1;
    end

    // always @(posedge clk) begin
    // 	$display("in_databits_phase2 => %d", in_databits_phase2);
    // 	$display("in_op_phase2 => %d", in_op_phase2);
    // 	$display("add_result_phase2 => %d", add_result_phase2);
    // 	$display("sub_result_phase2 => %d", sub_result_phase2);
    // 	$display("mul_result_phase2 => %d", mul_result_phase2);
    // end


  /* PHASE 3: produce the outputs */

    reg [DATABITS-1:0] out_databits_next;
    reg [1:0] out_op_next;
    reg [WIDTH-1:0] res_next;

    always @(*) begin
      if (reset) begin
        out_op_next = OP_NOP;
      end else begin
        out_op_next = in_op_phase2;
      end

      out_databits_next = in_databits_phase2;

      case (in_op_phase2)
        OP_NOP:
          res_next = 0;

        OP_ADD:
          res_next = add_result_phase2;

        OP_SUB:
          res_next = sub_result_phase2;

        OP_MULT:
          res_next = mul_result_phase2;
      endcase
    end

    always @(posedge clk) begin
      res <= res_next;
      out_op <= out_op_next;
      out_databits <= out_databits_next;
    end

endmodule

