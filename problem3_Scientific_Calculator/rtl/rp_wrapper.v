`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Revanth .A.H , Parthavi N.R
// 
// Create Date: 01.08.2026 13:52:59
// Design Name: 
// Module Name: rp_wrapper
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
module rp_wrapper (
    input  wire [31:0] operand_a,
    input  wire [31:0] operand_b,
    input  wire [1:0]  operation,
    output wire [31:0] result
);

    arithmetic rm_inst (
        .operand_a (operand_a),
        .operand_b (operand_b),
        .operation (operation),
        .result    (result)
    );

endmodule