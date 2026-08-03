`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DFX-FPGA-WORKSHOP
// Engineer: Revanth A.H , Parthavi N.R
// 
// Create Date: 01.08.2026 13:48:46
// Design Name: 
// Module Name: decision_engine
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
module decision_engine (
    input  wire [31:0] operand_a,
    input  wire [31:0] operand_b,
    input  wire [1:0]  operation,
    output reg  [31:0] result
);

always @(*) begin

    case (operation)

        // Maximum
        2'b00: begin
            if (operand_a > operand_b)
                result = operand_a;
            else
                result = operand_b;
        end

        // Minimum
        2'b01: begin
            if (operand_a < operand_b)
                result = operand_a;
            else
                result = operand_b;
        end

        // Equality
        // 1 = equal, 0 = not equal
        2'b10: begin
            if (operand_a == operand_b)
                result = 32'd1;
            else
                result = 32'd0;
        end

        // Absolute Difference |A-B|
        2'b11: begin
            if (operand_a >= operand_b)
                result = operand_a - operand_b;
            else
                result = operand_b - operand_a;
        end

        default:
            result = 32'd0;

    endcase

end

endmodule