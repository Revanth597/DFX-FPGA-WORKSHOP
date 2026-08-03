///////////////////////////////////////////////////////////////////
// Company: DFX-FPGA-WORKSHOP
// Engineer: Revanth.A.H 
// 
// Create Date: 01.08.2026 12:58:58
// Design Name: 
// Module Name: top
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


`timescale 1ns / 1ps

module top (
    input  wire       clk,
    input  wire       rst,
    output wire [7:0] led
);

    // ---------------------------------------------------------
    // Internal DSP interface
    // ---------------------------------------------------------
    reg  signed [15:0] sample_in;
    reg                sample_valid;

    wire signed [15:0] sample_out;
    wire               output_valid;


    // ---------------------------------------------------------
    // Slow sample generator
    //
    // The FPGA clock is 100 MHz, but we don't need to feed
    // a new sample every clock for this demonstration.
    // ---------------------------------------------------------
    reg [23:0] sample_counter;

    always @(posedge clk) begin
        if (rst) begin
            sample_counter <= 24'd0;
            sample_in      <= 16'sd0;
            sample_valid   <= 1'b0;
        end
        else begin
            sample_valid <= 1'b0;

            if (sample_counter == 24'd999999) begin
                sample_counter <= 24'd0;

                // Generate increasing test samples
                sample_in <= sample_in + 16'sd10;

                // One-clock valid pulse
                sample_valid <= 1'b1;
            end
            else begin
                sample_counter <= sample_counter + 1'b1;
            end
        end
    end


    // ---------------------------------------------------------
    // Reconfigurable Partition
    // ---------------------------------------------------------
    rp_wrapper RP (
        .clk          (clk),
        .rst          (rst),
        .sample_in    (sample_in),
        .sample_valid (sample_valid),
        .sample_out   (sample_out),
        .output_valid (output_valid)
    );


    // ---------------------------------------------------------
    // Display lower 8 bits of DSP output on Basys 3 LEDs
    // ---------------------------------------------------------
    assign led = sample_out[7:0];


endmodule