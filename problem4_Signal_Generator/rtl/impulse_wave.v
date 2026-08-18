`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DFX-FPGA-WORKSHOP
// Engineer: Revanth . A .H
// 
// Create Date: 01.08.2026 10:31:03
// Design Name: 
// Module Name: impulse_wave
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

module impulse_wave (
    input  wire       clk,
    input  wire       resetn,
    output wire    [7:0] wave_out
);
    reg [7:0] waveout;
    reg [27:0] counter;
    reg counter_next;

    always @(posedge clk) begin
        if (!resetn) begin
            counter  <= 0;
            waveout <= 8'h00;
        end
        else begin

            // 100 MHz clock
            // Generate an impulse approximately every 2 seconds
            if (counter == 28'd199_999_999) begin
                counter  <= 28'd0;
                waveout  <= 8'h00;
            end

            // Keep LEDs ON for approximately 200 ms
            else if (counter >= 28'd180_000_000) begin
                counter  <= counter_next;
                waveout <= 8'hFF;
            end

            else begin
                counter <= counter_next;
                waveout <= 8'h00;
            end

        end
    end
   
   always@(*)
   begin 
        counter_next = counter + 1;
   end
   
   assign wave_out = waveout;
   

endmodule