`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.08.2026 10:18:56
// Design Name: 
// Module Name: top_even_odd
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


// top_even_odd.v
module top_even_odd #(
    parameter N  = 8,   // signal length
    parameter W  = 8,   // sample width
    parameter AW = 3    // ceil(log2(N))
)(
    input  wire clk100mhz,
    input  wire btnC,        // center button = reset
    input  wire btnU,        // up button = start
    output wire [3:0] led_status  // LED0=Even, LED1=Odd, LED2=Both, LED3=Neither
);

    wire rst   = btnC;
    reg  start_sync, start_prev;
    wire start_pulse;

    // Simple debounce/edge-detect on btnU
    always @(posedge clk100mhz) begin
        start_sync <= btnU;
        start_prev <= start_sync;
    end
    assign start_pulse = start_sync & ~start_prev;

    wire [AW-1:0] addrA, addrB;
    wire signed [W-1:0] doutA, doutB;
    wire even_flag, odd_flag, done;

    // Dual-port BRAM preloaded with test signal
    bram_dualport #(.N(N), .W(W), .AW(AW)) u_bram (
        .clk(clk100mhz),
        .addrA(addrA), .addrB(addrB),
        .doutA(doutA), .doutB(doutB)
    );

    even_odd_classifier #(.N(N), .W(W), .AW(AW)) u_classifier (
        .clk(clk100mhz), .rst(rst), .start(start_pulse),
        .bram_doutA(doutA), .bram_doutB(doutB),
        .addrA(addrA), .addrB(addrB),
        .even_flag(even_flag), .odd_flag(odd_flag), .done(done)
    );

    assign led_status[0] = done &  even_flag & ~odd_flag; // Even
    assign led_status[1] = done & ~even_flag &  odd_flag; // Odd
    assign led_status[2] = done &  even_flag &  odd_flag; // Both (all-zero)
    assign led_status[3] = done & ~even_flag & ~odd_flag; // Neither

endmodule
