module register_file (
  input wire [1:0] rdReg,
  input wire [1:0] wtReg,
  input wire       rw,
  input wire       enable,
  input wire [3:0] inBus,
  output reg [3:0] outBus
);
  reg [3:0] register [0:3];

  always @(rdReg, wtReg, rw, enable) begin
    if (rw == 0) begin
      outBus = register[rdReg];
    end else if (enable) begin
      register[wtReg] = inBus;
    end
  end
endmodule
