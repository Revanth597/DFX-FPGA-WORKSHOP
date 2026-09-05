`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DFX-FPGA-WORKSHOP
// Engineer: Revanth A H
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
    input  wire resetn,
    input  wire start,
    input  wire signed [399:0] matA_flat ,  // 5x5 matrix A, flattened
    input  wire signed [399:0] matB_flat ,  // 5x5 matrix B, flattened
    output reg  signed [799:0] matC_flat ,  // 5x5 result matrix
    output reg  done
);
    
    reg [4:0] counter; // Counter to iterate through the 25 elements of the matrices
    reg signed [31:0] matC_flat_next; // Result matrix elements

    reg [1:0] state, next_state ;

    localparam IDLE=2'b00, 
               COMPUTE=2'b01, 
               FINISH=2'b10;

    // State transition logic
    always @ (posedge clk)
    begin 
            if(!resetn)
                    state <= IDLE;
            else
                    state <= next_state;
    end 

    // Next state logic
    always @(*)
    begin
        next_state = state; // Default to current state 
        case (state)
                IDLE: 
                begin
                    if (start) 
                        next_state = COMPUTE;
                    else 
                        next_state = IDLE;
                end
                COMPUTE: 
                begin
                    if(counter == 24)
                        next_state = FINISH;
                    else
                        next_state = COMPUTE;
                end
                FINISH: 
                begin
                    next_state = IDLE;
                end
                default:
                    next_state = IDLE;
        endcase
    end
    
    // state operation logic
    always @(posedge clk)
    begin
        if(!resetn)
        begin
            done <= 0;
            counter <= 0; // Reset counter on reset
            matC_flat <= 800'b0; // Initialize result matrix to zero
        end
        else 
        begin
           
            case (state)
                IDLE: 
                begin
                    done <= 0;
                    counter <= 0; // Reset counter when entering IDLE state
                end
                COMPUTE: 
                begin
                    // Add every corresponding element: C[i] = A[i] + B[i]
                    
                        matC_flat[counter*32+:32] <= matC_flat_next;
                        if(counter == 24) begin
                            counter <= 0; // Reset counter after processing all elements
                        end
                        else begin
                            counter <= counter + 1;
                        end
                
                end
                FINISH: 
                begin
                    done  <= 1;
                end 
                default:
                begin   
                    done <= 0;
                    counter <= 0; // Reset counter on default case
                end
            endcase
        end
    end


    always @(*)
begin
    matC_flat_next =
        {{16{matA_flat[counter*16+15]}},
         matA_flat[counter*16+:16]} 
        +
        {{16{matB_flat[counter*16+15]}},
         matB_flat[counter*16+:16]};
end
endmodule