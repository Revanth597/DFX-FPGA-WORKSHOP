`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: DFX-FPGA-WORKSHOP
// Engineer: Revanth. A .H
// 
// Create Date: 01.08.2026 10:31:03
// Design Name: 
// Module Name: sawtooth_wave
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



module sawtooth_wave (
    input  wire       clk,
    input  wire       resetn,
    output wire  [7:0] wave_out
);
        reg [7:0]  waveout;
        reg [23:0] divider;

        reg [7:0]  waveout_next;
        reg [23:0] divider_next;

always @(posedge clk)
begin
        if (!resetn)
        begin
                divider <= 24'd0;
                waveout <= 8'd0;
        end
        else
        begin
                if (divider == 24'd9_999_999)
                begin
                        divider <= 24'd0;
                        waveout <= waveout_next;
                end
                else
                begin
                        divider <= divider_next;
                end
        end
end

always @(*)
begin
        waveout_next  = waveout + 1'b1;
        divider_next  = divider + 1'b1;
end

assign wave_out = waveout;
  

endmodule