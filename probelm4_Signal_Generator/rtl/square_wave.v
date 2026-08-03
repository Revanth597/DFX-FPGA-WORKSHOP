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


module square_wave #(
    parameter HALF_PERIOD = 24'd5000000,
    parameter FULL_PERIOD = 24'd10000000
)(
    input  wire clk,
    input  wire rst,
    output reg  wave_out
);

    reg [23:0] counter;

    always @(posedge clk) begin
        if (rst) begin
            counter  <= 0;
            wave_out <= 0;
        end
        else begin
            counter <= counter + 1;

            if (counter < HALF_PERIOD)
                wave_out <= 1'b1;
            else
                wave_out <= 1'b0;

            if (counter == FULL_PERIOD)
                counter <= 0;
        end
    end

endmodule