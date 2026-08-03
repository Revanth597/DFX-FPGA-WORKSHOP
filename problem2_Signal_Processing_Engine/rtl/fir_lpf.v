`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DFX-FPGA-WORKSHOP
// Engineer: Revanth.A.H 
// 
// Create Date: 01.08.2026 12:47:42
// Design Name: 
// Module Name: fir_lpf
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

module fir_lpf (
    input  wire               clk,
    input  wire               rst,
    input  wire signed [15:0] sample_in,
    input  wire               sample_valid,

    output reg  signed [15:0] sample_out,
    output reg                output_valid
);

    // Previous input samples
    reg signed [15:0] x1;
    reg signed [15:0] x2;

    // Accumulator with extra width
    reg signed [18:0] fir_sum;

    /*
       3-tap FIR low-pass filter

       Coefficients:
           h[0] = 1/4
           h[1] = 1/2
           h[2] = 1/4

       y[n] = (x[n] + 2*x[n-1] + x[n-2]) / 4
    */

    always @(posedge clk) begin

        if (rst) begin

            x1           <= 16'sd0;
            x2           <= 16'sd0;

            fir_sum      <= 19'sd0;

            sample_out   <= 16'sd0;
            output_valid <= 1'b0;

        end
        else begin

            output_valid <= 1'b0;

            if (sample_valid) begin

                // FIR calculation
                fir_sum <= sample_in
                         + (x1 <<< 1)
                         + x2;

                sample_out <=
                    (sample_in
                    + (x1 <<< 1)
                    + x2) >>> 2;

                output_valid <= 1'b1;

                // Shift delay line
                x2 <= x1;
                x1 <= sample_in;

            end
        end
    end

endmodule