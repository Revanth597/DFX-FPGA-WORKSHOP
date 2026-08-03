`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DFX-FPGA-WORKSHOP
// Engineer:  Parthavi N.R
// 
// Create Date: 01.08.2026 13:48:46
// Design Name: 
// Module Name: arithmetic
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module arithmetic (
    input  wire [31:0] operand_a,
    input  wire [31:0] operand_b,
    input  wire [1:0]  operation,
    output reg  [31:0] result
);

always @(*) begin
    case (operation)

        2'b00: result = operand_a + operand_b;  // ADD

        2'b01: result = operand_a - operand_b;  // SUBTRACT

        2'b10: result = operand_a * operand_b;  // MULTIPLY

        2'b11: begin                            // DIVIDE
            if (operand_b != 0)
                result = operand_a / operand_b;
            else
                result = 32'd0;
        end

        default: result = 32'd0;

    endcase
end

endmodule