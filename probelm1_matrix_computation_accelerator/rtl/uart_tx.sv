//////////////////////////////////////////////////////////////////////////////////
// Company: DFX-FPGA-WORKSHOP
// Engineer: Revanth A H
// Create Date: 01.08.2026 11:22:05
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
    input  wire       clk,
    input  wire       resetn,
    input  wire [7:0] data_in,
    input  wire       start,
    output reg        tx,
    output reg        busy
);

localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

localparam IDLE      = 2'b00,
           START_BIT = 2'b01,
           DATA_BITS = 2'b10,
           STOP_BIT  = 2'b11;

reg [1:0]  state, next_state;
reg [15:0] clk_count;
reg [2:0]  bit_index;
reg [7:0]  tx_shift;

// State transition register
always @(posedge clk) begin
    if (!resetn)
        state <= IDLE;
    else
        state <= next_state;
end

// Next state combinational logic
always @(*) begin
    case (state)

        IDLE: begin
            if (start)
                next_state = START_BIT;
            else
                next_state = IDLE;
        end

        START_BIT: begin
            if (clk_count == CLKS_PER_BIT-1)
                next_state = DATA_BITS;
            else
                next_state = START_BIT;
        end

        DATA_BITS: begin
            if (clk_count == CLKS_PER_BIT-1) begin
                if (bit_index == 7)
                    next_state = STOP_BIT;
                else
                    next_state = DATA_BITS;
            end
            else begin
                next_state = DATA_BITS;
            end
        end

        STOP_BIT: begin
            if (clk_count == CLKS_PER_BIT-1)
                next_state = IDLE;
            else
                next_state = STOP_BIT;
        end

        default: next_state = IDLE;

    endcase
end

// Data path logic
always @(posedge clk) begin
    if (!resetn) begin
        clk_count <= 0;
        bit_index <= 0;
        tx_shift  <= 0;
        tx        <= 1'b1;
        busy      <= 1'b0;
    end
    else begin
        case (state)

            IDLE: begin
                tx        <= 1'b1;
                clk_count <= 0;
                bit_index <= 0;
                busy      <= 1'b0;
            end

            START_BIT: begin
                tx   <= 1'b0;
                busy <= 1'b1;

                if (clk_count < CLKS_PER_BIT-1) begin
                    clk_count <= clk_count + 1;
                end
                else begin
                    clk_count <= 0;
                    tx_shift  <= data_in;
                end
            end

            DATA_BITS: begin
                tx <= tx_shift[bit_index];

                if (clk_count < CLKS_PER_BIT-1) begin
                    clk_count <= clk_count + 1;
                end
                else begin
                    clk_count <= 0;

                    if (bit_index < 7)
                        bit_index <= bit_index + 1;
                    else
                        bit_index <= 0;
                end
            end

            STOP_BIT: begin
                tx <= 1'b1;

                if (clk_count < CLKS_PER_BIT-1) begin
                    clk_count <= clk_count + 1;
                end
                else begin
                    clk_count <= 0;
                    busy      <= 1'b0;
                end
            end

        endcase
    end
end

endmodule