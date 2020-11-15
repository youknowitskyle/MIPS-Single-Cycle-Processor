// Top level system including MIPS and memories

module top(input clk, reset);

  wire [31:0] pc, instr, readdata;
  wire [31:0] writedata, dataadr;
  wire        memwrite;
  
  // processor and memories are instantiated here 
  mips mips(.clk( clk), .reset(reset), .pc(pc), .instr(instr), .memwrite(memwrite), .aluout(dataadr), .writedata(writedata), .readdata(readdata));
  imem imem(.a(pc[7:2]), .rd(instr));
  dmem dmem(.clk(clk), .we(memwrite), .a(dataadr), .wd(writedata), .rd(readdata));

endmodule
