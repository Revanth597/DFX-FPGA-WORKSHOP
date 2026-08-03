
//////////////////////////////////////////////////////////////////////////////////
// Company: DFX-FPGA-WORKSHOP
// Engineer: Revanth.A.H 
// 
// Create Date: 01.08.2026 12:58:07
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

`timescale 1ns / 1ps

module rp_wrapper (
    input  wire               clk,
    input  wire               rst,
    input  wire signed [15:0] sample_in,
    input  wire               sample_valid,

    output wire signed [15:0] sample_out,
    output wire               output_valid
);

    // Default Reconfigurable Module:
    // Moving Average Filter
    moving_average rm_inst (
        .clk(clk),
        .rst(rst),
        .sample_in(sample_in),
        .sample_valid(sample_valid),
        .sample_out(sample_out),
        .output_valid(output_valid)
    );

endmodule