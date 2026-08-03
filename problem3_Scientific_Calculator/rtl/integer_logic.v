`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Revanth .A.H , Parthavi N.R
// 
// Create Date: 01.08.2026 13:52:59
// Design Name: 
// Module Name: integer_logic
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

module integer_logic (
    input  wire [31:0] operand_a,
    input  wire [31:0] operand_b,
    input  wire [1:0]  operation,
    output reg  [31:0] result
);

always @(*) begin
    case (operation)

        2'b00: result = operand_a & operand_b;   // AND

        2'b01: result = operand_a | operand_b;   // OR

        2'b10: result = operand_a ^ operand_b;   // XOR

        2'b11: result = operand_a << operand_b;  // LEFT SHIFT

        default: result = 32'd0;

    endcase
end

endmodule
