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


`timescale 1ns / 1ps

module top(
    input  wire       clk,
    input  wire       resetn,
    output wire [7:0] wave_out
);

    // Reconfigurable Partition
    rp_wrapper RP (
        .clk(clk),
        .resetn(resetn),
        .wave_out(wave_out)
    );

endmodule