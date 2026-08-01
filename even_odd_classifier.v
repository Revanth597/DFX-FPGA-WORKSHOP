`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.08.2026 10:19:39
// Design Name: 
// Module Name: even_odd_classifier
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

// even_odd_classifier.v (from previous step, cleaned up)
module even_odd_classifier #(
    parameter N=8, W=8, AW=3
)(
    input  wire clk, rst, start,
    input  wire signed [W-1:0] bram_doutA, bram_doutB,
    output reg  [AW-1:0] addrA, addrB,
    output reg  even_flag, odd_flag, done
);
    reg [AW-1:0] i;
    reg [2:0] state;
    localparam IDLE=0, SETADDR=1, WAIT=2, EVAL=3, DONE_ST=4;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE; i <= 0;
            even_flag <= 1; odd_flag <= 1; done <= 0;
            addrA <= 0; addrB <= 0;
        end else case (state)
            IDLE: begin
                done <= 0;
                if (start) begin
                    i <= 0;
                    even_flag <= 1; odd_flag <= 1;
                    addrA <= 0; addrB <= N-1;
                    state <= WAIT;          // go straight to WAIT after setting first addr
                end
            end
            WAIT: state <= EVAL;            // 1 full cycle for BRAM read to land in doutA/doutB
            EVAL: begin
                if ((bram_doutA - bram_doutB) != 0) even_flag <= 0;
                if ((bram_doutA + bram_doutB) != 0) odd_flag  <= 0;
                if (i < (N/2)-1) begin
                    i <= i + 1;
                    addrA <= i + 1;
                    addrB <= N - 1 - (i + 1);
                    state <= WAIT;           // <-- back to WAIT, not straight to EVAL
                end else begin
                    state <= DONE_ST;
                end
            end
            DONE_ST: begin
                done <= 1;
                state <= IDLE;
            end
        endcase
    end
endmodule