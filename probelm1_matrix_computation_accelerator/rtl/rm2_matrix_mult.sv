`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DFX-FPGA-WORKSHOP
// Engineer: Revanth A H
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
    input  wire resetn,
    input  wire start,
    input  wire signed [399:0] matA_flat,  // 5x5 matrix of signed 16-bit integers
    input  wire signed [399:0] matB_flat,  // 5x5 matrix of signed 16-bit integers
    output reg  signed [799:0] matC_flat,  // 5x5 matrix of signed 32-bit integers
    output reg  done
);
    reg [2:0] state, next_state;
    reg [2:0] r, k, c; // row, column, and k indices
    reg signed [31:0] acc_next;


    reg signed [31:0] acc;
    localparam IDLE=3'b000, 
               MAC=3'b001, 
               STORE=3'b010, 
               NEXT=3'b011, 
               FINISH=3'b100;

// State transition logic
    always @(posedge clk) begin
            if (!resetn) 
                state <= IDLE;
            else 
                state <= next_state;
    end

// Next state logic
    always@(*)
        begin
            
            next_state = state; // Default next state
            
            case(state)
                IDLE: 
                    if(start)
                        next_state = MAC;
                    else
                        next_state = IDLE;
                MAC:
                    if(k == 4)
                        next_state = STORE;
                    else
                        next_state = MAC;
                STORE:
                    next_state = NEXT;
                NEXT:
                    if(c == 4 && r == 4)
                        next_state = FINISH;
                    else
                        next_state = MAC;
                FINISH: 
                    next_state = IDLE;  
                default: 
                    next_state = IDLE;
            endcase
        end 
                    

                

// Output and internal register updates
    always @(posedge clk) begin
        if (!resetn) 
        begin
            done  <= 0;
            r <= 0;
            c <= 0;
            k <= 0;
            acc <= 0;
            matC_flat <= 800'b0;
        end 
        else 
        begin
            case (state)
                IDLE: 
                begin
                    done <= 0;
                    if (start) begin
                        r <= 0; 
                        c <= 0; 
                        k <= 0; 
                        acc <= 0;
                    end
                end
                MAC: 
                begin
                    acc <= acc_next;
                    if (k == 4) 
                         k <= 0; // Reset k for the next column
                    else 
                        k <= k + 1; // Increment k for the next multiplication
                end
                STORE: 
                begin
                    matC_flat[(r*5 + c)*32 +: 32] <= acc;
                    acc <= 0;
                    k <= 0;
                  
                end
                NEXT: 
                begin
                    if (c == 4) 
                    begin
                        c <= 0;
                        if (r == 4) 
                             r <= 0; // Reset r for the next row
                        else 
                        begin 
                            r <= r + 1; // Increment r for the next row
                            
                        end
                    end 
                    else 
                    begin
                        c <= c + 1; // Increment c for the next column
                    end
                end
                FINISH: 
                
                    begin
                        if (!start)
                            next_state = IDLE;
                        else
                            next_state = FINISH;
                    end
            endcase
        end
    end



    always @(*)
    begin 
        
            acc_next = acc
                    + $signed(matA_flat[(r*5 + k)*16 +: 16])
                    * $signed(matB_flat[(k*5 + c)*16 +: 16]);
        
    end

endmodule