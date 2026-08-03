`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DFX-FPGA-WORKSHOP 
// Engineer: Mithil kumar
// 
// Create Date: 01.08.2026 11:30:57
// Design Name: 
// Module Name: rm3_matrix_transpose
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


module rm3_matrix_transpose (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire signed [15:0] matA_flat [0:24],
    input  wire signed [15:0] matB_flat [0:24],  // unused, kept so port list matches RM1/RM2
    output reg  signed [31:0] matC_flat [0:24],
    output reg  done
);
    integer row, col;
    reg state;
    localparam IDLE=0, FINISH=1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done  <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        // C[col][row] = A[row][col]
                        // flattened: C[col*5+row] = A[row*5+col]
                        for (row=0; row<5; row=row+1)
                            for (col=0; col<5; col=col+1)
                                matC_flat[col*5 + row] <= matA_flat[row*5 + col];
                        state <= FINISH;
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
