
//////////////////////////////////////////////////////////////////////////////////
// Company: DFX-FPGA-WORKSHOP
// Engineer: Mithil kumar
// 
// Create Date: 01.08.2026 11:43:02
// Design Name: 
// Module Name: uart_tx
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


module uart_tx #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 115200
)(
    input  wire clk,
    input  wire rst,
    input  wire [7:0] data_in,
    input  wire start,        // pulse high for 1 cycle to begin sending a byte
    output reg  tx,
    output reg  busy          // high while a byte is currently being sent
);
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    localparam IDLE=0, START_BIT=1, DATA_BITS=2, STOP_BIT=3;
    reg [1:0] state = IDLE;
    reg [15:0] clk_count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] tx_shift = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            tx <= 1'b1;      // idle line is high
            busy <= 0;
            clk_count <= 0;
            bit_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    busy <= 0;
                    if (start) begin
                        tx_shift  <= data_in;
                        busy      <= 1;
                        clk_count <= 0;
                        state     <= START_BIT;
                    end
                end
                START_BIT: begin
                    tx <= 1'b0;   // drive start bit
                    if (clk_count < CLKS_PER_BIT-1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        bit_index <= 0;
                        state <= DATA_BITS;
                    end
                end
                DATA_BITS: begin
                    tx <= tx_shift[bit_index];
                    if (clk_count < CLKS_PER_BIT-1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        if (bit_index < 7) bit_index <= bit_index + 1;
                        else state <= STOP_BIT;
                    end
                end
                STOP_BIT: begin
                    tx <= 1'b1;   // drive stop bit
                    if (clk_count < CLKS_PER_BIT-1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        busy  <= 0;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule