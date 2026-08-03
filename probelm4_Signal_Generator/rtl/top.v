`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DFX-FPGA-WORKSHOP
// Engineer: Revanth A H
// 
// Create Date: 01.08.2026 10:28:46
// Design Name: 
// Module Name: top
// Project Name: Signal Generator
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


module top(
    input  wire clk,
    input  wire rst,
    output wire wave_out
);

wire wave_signal;

// Reconfigurable Partition
rp_wrapper RP (
    .clk(clk),
    .rst(rst),
    .wave_out(wave_signal)
);

assign wave_out = wave_signal;

endmodule
