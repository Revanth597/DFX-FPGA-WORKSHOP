`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Revanth. A .H
// 
// Create Date: 01.08.2026 10:31:03
// Design Name: 
// Module Name: sawtooth_wave
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



module sawtooth_wave (
    input  wire       clk,
    input  wire       rst,
    output reg  [7:0] wave_out
);

    reg [23:0] divider;

    always @(posedge clk) begin
        if (rst) begin
            divider  <= 0;
            wave_out <= 0;
        end
        else begin
            if (divider == 24'd9_999_999) begin
                divider  <= 0;
                wave_out <= wave_out + 1'b1;
            end
            else begin
                divider <= divider + 1'b1;
            end
        end
    end

endmodule