// single-cycle MIPS processor
// instantiates a controller and a datapath module

module mips(input          clk, reset,
            output  [31:0] pc,
            input   [31:0] instr,
            output         memwrite,
            output  [31:0] aluout, writedata,
            input   [31:0] readdata);

  wire        memtoreg, branch,
               pcsrc, zero,
               alusrc, regdst, regwrite, jump;
  wire [2:0]  alucontrol;

  controller c(instr[31:26], instr[5:0], zero,
               memtoreg, memwrite, pcsrc,
               alusrc, regdst, regwrite, jump,
               alucontrol);
  datapath dp(clk, reset, memtoreg, pcsrc,
              alusrc, regdst, regwrite, jump,
              alucontrol,
              zero, pc, instr,
              aluout, writedata, readdata);
endmodule


module controller(input   [5:0] op, funct,
                  input         zero,
                  output reg       memtoreg, memwrite,
                  output reg       pcsrc, alusrc,
                  output reg       regdst, regwrite,
                  output reg       jump,
                  output reg  [2:0] alucontrol);

    reg [1:0] alu_op;
always @(op, funct) begin
		if(op == 6'h0 & funct == 6'h20) begin //add
			regdst = 1'b1;
			memtoreg = 1'b0;
			jump = 1'b0;
			pcsrc = 1'b0 && zero;
			memwrite = 1'b0;
			alusrc = 1'b0;
			regwrite = 1'b1;
        end
		if(op == 6'h0 & funct == 6'h22) begin //sub
			regdst = 1;
			memtoreg = 0;
			jump = 0;
			pcsrc = 0 && zero;
			memwrite = 0;
			alusrc = 0;
			regwrite = 1;
        end
		if(op == 6'h0 & funct == 6'h24) begin //and
			regdst = 1;
			memtoreg = 0;
			jump = 0; 
			pcsrc = 0 && zero;
			memwrite = 0;
			alusrc = 0;
			regwrite = 1;
        end
		if(op == 6'h0 & funct == 6'h25) begin //or
			regdst = 1;
			memtoreg = 0;
			jump = 0;
			pcsrc = 0 && zero;
			memwrite = 0;
			alusrc = 0;
			regwrite = 1;
        end
		if(op == 6'h0 & funct == 6'h2A) begin //slt
			regdst = 1;
			memtoreg = 0;
			jump = 0;
			pcsrc = 0 && zero;
			memwrite = 0;
			alusrc = 0;
			regwrite = 1;
        end
		if(op == 6'h23) begin //lw
			regdst = 0;
			memtoreg = 1;
			jump = 0;
			pcsrc = 0 && zero;
			memwrite = 0;
			alusrc = 1;
			regwrite = 1;
        end
		if(op == 6'h2B) begin //sw
			regdst = 0;
			memtoreg = 0;
			jump = 0;
			pcsrc = 0 && zero;
			memwrite = 1;
			alusrc = 1;
			regwrite = 0;
        end
		if(op == 6'h04) begin //beq
			regdst = 0;
			memtoreg = 0;
			jump = 0;
			pcsrc = 1 && zero;
			memwrite = 0;
			alusrc = 0;
			regwrite = 0;
        end
		if(op == 6'h08) begin //addi
			regdst = 0;
			memtoreg = 0;
			jump = 0;
			pcsrc = 0 && zero;
			memwrite = 0;
			alusrc = 1;
			regwrite = 1;
        end
		if(op == 6'h02) begin //j
			regdst = 0;
			memtoreg = 0;
			jump = 1;
			pcsrc = 0 & zero;
			memwrite = 0;
			alusrc = 0;
			regwrite = 0;
        end
		if(op == 6'h0D) begin //ori
			regdst = 0;
			memtoreg = 0;
			jump = 0;
			pcsrc = 0 & zero;
			memwrite = 0;
			alusrc = 1;
			regwrite = 1;
        end
		if(op == 6'h05) begin //bne
			regdst = 0;
			memtoreg = 0;
			jump = 0;
			pcsrc = 1 & (zero ^ 1);
			memwrite = 0;
			alusrc = 0;
			regwrite = 0;
        end
end

always @(op or funct) begin                                         // ALU op decoder
		casex ({op, funct})
			12'b000100xxxxxx : alucontrol = 3'b110;
            12'b000101xxxxxx : alucontrol = 3'b110;
			12'b001010xxxxxx : alucontrol = 3'b111;
			12'b001000xxxxxx : alucontrol = 3'b010;
            12'b001101xxxxxx : alucontrol = 3'b001;
			12'bxxxxxx100000 : alucontrol = 3'b010;
			12'bxxxxxx100010 : alucontrol = 3'b110;
			12'bxxxxxx100100 : alucontrol = 3'b000;
			12'bxxxxxx100101 : alucontrol = 3'b001;
			12'bxxxxxx101010 : alucontrol = 3'b111;
			default          : alucontrol = 3'b010;
		endcase
	end

endmodule


module datapath(input          clk, reset,
                input          memtoreg, pcsrc,
                input          alusrc, regdst,
                input          regwrite, jump,
                input   [2:0]  alucontrol,
                output         zero,
                output  reg [31:0] pc,
                input   [31:0] instr,
                output  [31:0] aluout, writedata,
                input   [31:0] readdata);

    wire [31:0] pc_plus_4;              // Initialize pc + 4 value
    assign pc_plus_4 = pc + 4;

    wire [31:0] imm_ext;                // Declare immediate extension

    wire [31:0] pc_jump;                                            // Initialize pc jump address
    assign pc_jump = {pc_plus_4[31:28], instr[25:0], 2'b00};

    wire [31:0] pc_branch;                                          // Initialize branch address
    assign pc_branch = pc_plus_4 + {imm_ext[29:0], 2'b00};          

    wire [31:0] pc_next;                                            // Initialize next pc address based on control signals
    assign pc_next = jump ? pc_jump : (pcsrc ? pc_branch : pc_plus_4);

    always @(posedge clk) begin                                     // Set pc to its next value
        if(~reset) begin
            pc = pc_next;
        end else begin
            pc = 32'h00000000;
        end
        //pc = 32'h00000004;
    end

    wire [5:0] rt;                                                  // Initialize inputs into register
    assign rt = instr[20:16];

    wire [5:0] rd;
    assign rd = instr[15:11];

    wire [4:0] write_reg;                                           // Initialize writeReg
    assign write_reg = regdst ? rd : rt;

    wire [31:0] result;                                             // initialize result wire
    assign result = memtoreg ? readdata : aluout;

    reg [31:0] reg_data1;                                           // initialize register outputs
    reg [31:0] reg_data2;
    reg [31:0] regmem[31:0];                                        // initialize register file

    always @(instr[25:21] or regmem[instr[25:21]]) begin            // set register output to correct values
        if (0 == instr[25:21]) begin
            reg_data1 = 0;
        end else begin
            reg_data1 = regmem[instr[25:21]];
        end
    end

    always @(instr[20:16] or regmem[instr[20:16]]) begin
        if (0 == instr[20:16]) begin
            reg_data2 = 0;
        end else begin
            reg_data2 = regmem[instr[20:16]];
        end
    end

    always @(posedge clk) begin                                    // set register file write input to result if regwrite is 1
        if(1'b1 == regwrite) begin
            regmem[write_reg] = result;
        end
    end

    wire [31:0] src_a;                                            // initiliaze alu inputs
    wire [31:0] src_b;
    wire c_out;

    assign src_a = reg_data1;                                       // wire alu inputs to correct values
    assign src_b = alusrc ? imm_ext : reg_data2;

    wire [31:0] alu_out;                                            // initialize alu output

    ALU alu (                                                     // instantiate alu module
        .a (src_a),
        .b (src_b),
        .f (alucontrol),
        .y (alu_out),
        .zero (zero)
    );

    assign aluout = alu_out;


    reg [31:0] odata;                                               // perform sign and zero extension
    wire [15:0] idata;
    assign idata = instr[15:0];
    reg [31:0] zerodata;

    always @(idata) begin
        odata = {{16{idata[15]}}, idata};
        zerodata = {16'h0000, idata};
    end

    assign imm_ext = (instr[31:26] == 6'h44D) ? zerodata : odata;


    assign writedata = reg_data2;                                   // set writedata to register file second output

                
endmodule
