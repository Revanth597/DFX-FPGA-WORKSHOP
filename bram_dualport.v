`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.08.2026 10:19:18
// Design Name: 
// Module Name: bram_dualport
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


// bram_dualport.v - preloaded test signal (edit values as needed)
module bram_dualport #(
    parameter N = 8, W = 8, AW = 3
)(
    input  wire clk,
    input  wire [AW-1:0] addrA, addrB,
    output reg signed [W-1:0] doutA, doutB
);
    reg signed [W-1:0] mem [0:N-1];

    initial begin
        // Example: symmetric EVEN signal {1,2,3,4,4,3,2,1}
        mem[0]=1; mem[1]=2; mem[2]=3; mem[3]=4;
        mem[4]=4; mem[5]=3; mem[6]=2; mem[7]=1;
        // Uncomment for ODD test instead: {1,2,3,4,-4,-3,-2,-1}
        // Uncomment for NEITHER test: {1,2,3,4,5,6,7,8}
    end

    always @(posedge clk) begin
        doutA <= mem[addrA];
        doutB <= mem[addrB];
    end
endmodule