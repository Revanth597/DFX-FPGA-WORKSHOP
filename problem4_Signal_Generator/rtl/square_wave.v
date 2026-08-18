`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.08.2026 10:32:39
// Design Name: 
// Module Name: square_wave
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

module square_wave #(
    parameter HALF_PERIOD = 26'd25_000_000,
    parameter FULL_PERIOD = 26'd50_000_000
)(
    input  wire       clk,
    input  wire       resetn,
    output wire  [7:0] wave_out
);
    reg [25:0] counter_next;   
    reg [7:0] waveout;
    reg [25:0] counter;

    always @(posedge clk) begin
        if (!resetn) begin
            counter  <= 26'd0;
            waveout <= 8'h00;
        end
        else begin

            if (counter < HALF_PERIOD)
                waveout <= 8'hFF;
            else
                waveout <= 8'h00;

            if (counter >= FULL_PERIOD - 1)
                counter <= 26'd0;
            else
                counter <= counter_next;

        end
    end
    
    always@(*)
    begin
        counter_next = counter + 1'b1;
    end 
        
    assign wave_out = waveout;

endmodule