module alu_one(input signed [31:0] a, b,
            input [2:0] f,
            output reg [31:0] y,
            output reg zero);
    always @ (a, b, f) begin
        case (f)
            3'b000: y = a & b;
            3'b001: y = a | b;
            3'b010: y = a + b;
            3'b100: y = a & ~b;
            3'b101: y = a | ~b;
            3'b110: y = a - b;
            3'b111: y = a < b ? 32'b1 : 32'b0;
        endcase
        if (y == 0)
            zero = 1;
        else
            zero = 0;
    end

endmodule
