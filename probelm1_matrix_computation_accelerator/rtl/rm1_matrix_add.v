`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DFX-FPGA-WORKSHOP
// Engineer: Mithil kumar
// 
// Create Date: 01.08.2026 11:16:36
// Design Name: 
// Module Name: rm1_matrix_add
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

module rm1_matrix_add (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire signed [15:0] matA_flat [0:24],  // 5x5 matrix A, flattened
    input  wire signed [15:0] matB_flat [0:24],  // 5x5 matrix B, flattened
    output reg  signed [31:0] matC_flat [0:24],  // 5x5 result matrix
    output reg  done
);
    integer i;
    reg [1:0] state;
    localparam IDLE=0, COMPUTE=1, FINISH=2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done  <= 0;
            for (i=0; i<25; i=i+1) matC_flat[i] <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) state <= COMPUTE;
                end
                COMPUTE: begin
                    // Add every corresponding element: C[i] = A[i] + B[i]
                    for (i=0; i<25; i=i+1)
                        matC_flat[i] <= matA_flat[i] + matB_flat[i];
                    state <= FINISH;
                end
                FINISH: begin
                    done  <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule