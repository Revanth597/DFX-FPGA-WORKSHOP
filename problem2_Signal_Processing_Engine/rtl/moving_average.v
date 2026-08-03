`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DFX-FPGA-WORKSHOP
// Engineer: Revanth.A.H 
// 
// Create Date: 01.08.2026 12:43:27
// Design Name: 
// Module Name: moving_average
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


module moving_average (
    input  wire               clk,
    input  wire               rst,
    input  wire signed [15:0] sample_in,
    input  wire               sample_valid,

    output reg  signed [15:0] sample_out,
    output reg                output_valid
);

    // Store the previous 4 samples
    reg signed [15:0] x0;
    reg signed [15:0] x1;
    reg signed [15:0] x2;
    reg signed [15:0] x3;

    // Extra width prevents overflow while adding four 16-bit values
    reg signed [17:0] sum;

    reg [2:0] sample_count;

    always @(posedge clk) begin
        if (rst) begin
            x0           <= 16'sd0;
            x1           <= 16'sd0;
            x2           <= 16'sd0;
            x3           <= 16'sd0;

            sum           <= 18'sd0;
            sample_count  <= 3'd0;

            sample_out    <= 16'sd0;
            output_valid  <= 1'b0;
        end
        else begin
            output_valid <= 1'b0;

            if (sample_valid) begin

                // Current four-sample window:
                // new sample + previous three samples
                sum <= sample_in + x0 + x1 + x2;

                // Shift samples
                x3 <= x2;
                x2 <= x1;
                x1 <= x0;
                x0 <= sample_in;

                // Don't claim a valid moving average until
                // four real samples have been received.
                if (sample_count >= 3) begin
                    sample_out <=
                        (sample_in + x0 + x1 + x2) >>> 2;

                    output_valid <= 1'b1;
                end
                else begin
                    sample_count <= sample_count + 1'b1;
                end

            end
        end
    end

endmodule
