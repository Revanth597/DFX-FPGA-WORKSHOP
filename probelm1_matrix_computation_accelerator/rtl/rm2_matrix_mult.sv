`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DFX-FPGA-WORKSHOP
// Engineer: Mithil kumar
// 
// Create Date: 01.08.2026 11:22:05
// Design Name: 
// Module Name: rm2_matrix_mult
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


module rm2_matrix_mult (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire signed [15:0] matA_flat [0:24],
    input  wire signed [15:0] matB_flat [0:24],
    output reg  signed [31:0] matC_flat [0:24],
    output reg  done
);
    reg [2:0] state;
    reg [2:0] r, c, k;
    reg signed [31:0] acc;
    localparam IDLE=0, MAC=1, STORE=2, NEXT=3, FINISH=4;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done  <= 0;
            r <= 0; c <= 0; k <= 0; acc <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        r <= 0; c <= 0; k <= 0; acc <= 0;
                        state <= MAC;
                    end
                end
                MAC: begin
                    acc <= acc + matA_flat[r*5 + k] * matB_flat[k*5 + c];
                    if (k == 4) state <= STORE;
                    else        k <= k + 1;
                end
                STORE: begin
                    matC_flat[r*5 + c] <= acc;
                    acc <= 0;
                    k <= 0;
                    state <= NEXT;
                end
                NEXT: begin
                    if (c == 4) begin
                        c <= 0;
                        if (r == 4) state <= FINISH;
                        else begin r <= r + 1; state <= MAC; end
                    end else begin
                        c <= c + 1;
                        state <= MAC;
                    end
                end
                FINISH: begin
                    done  <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule