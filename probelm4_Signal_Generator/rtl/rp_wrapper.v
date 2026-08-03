`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.08.2026 10:31:03
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


module rp_wrapper(
    input  wire clk,
    input  wire rst,
    output wire wave_out
);

square_wave rm_inst(
    .clk(clk),
    .rst(rst),
    .wave_out(wave_out)
);

endmodule