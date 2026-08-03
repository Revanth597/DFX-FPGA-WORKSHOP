`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.08.2026 12:52:34
// Design Name: 
// Module Name: peak_detection_engine
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


module peak_detector (
    input  wire               clk,
    input  wire               rst,
    input  wire signed [15:0] sample_in,
    input  wire               sample_valid,

    output reg  signed [15:0] sample_out,
    output reg                output_valid
);

    reg signed [15:0] peak_value;

    always @(posedge clk) begin

        if (rst) begin

            peak_value   <= -16'sd32768;
            sample_out   <= 16'sd0;
            output_valid <= 1'b0;

        end
        else begin

            output_valid <= 1'b0;

            if (sample_valid) begin

                // New peak detected
                if (sample_in > peak_value) begin

                    peak_value <= sample_in;
                    sample_out <= sample_in;

                end
                else begin

                    // Keep previous peak
                    sample_out <= peak_value;

                end

                output_valid <= 1'b1;

            end

        end

    end

endmodule