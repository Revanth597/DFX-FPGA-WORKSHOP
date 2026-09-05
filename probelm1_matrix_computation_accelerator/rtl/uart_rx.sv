//////////////////////////////////////////////////////////////////////////////////
// Company: DFX-FPGA-WORKSHOP
// Engineer: Revanth A H
// Create Date: 01.08.2026 11:22:05
// Design Name: 
// Module Name: uart_rx
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

module uart_rx #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       resetn,
    input  wire       rx,
    output reg [7:0]  data_out,
    output reg       data_valid
);

localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

localparam IDLE  = 2'b00,
           START = 2'b01,
           DATA  = 2'b10,
           STOP  = 2'b11;

reg [1:0]  state, next_state;
reg [15:0] clk_count;
reg [2:0]  bit_index;
reg [7:0]  rx_shift;

reg rx_sync_1;
reg rx_sync_2;

// Synchronizer
always @(posedge clk) begin
    if (!resetn) begin
        rx_sync_1 <= 1'b1;
        rx_sync_2 <= 1'b1;
    end
    else begin
        rx_sync_1 <= rx;
        rx_sync_2 <= rx_sync_1;
    end
end

// State register
always @(posedge clk) begin
    if (!resetn)
        state <= IDLE;
    else
        state <= next_state;
end

// Next state logic
always @(*) begin
    case (state)

        IDLE: begin
            if (rx_sync_2 == 1'b0)
                next_state = START;
            else
                next_state = IDLE;
        end

        START: begin
            if (clk_count == (CLKS_PER_BIT/2)-1) begin
                if (rx_sync_2 == 1'b0)
                    next_state = DATA;
                else
                    next_state = IDLE;
            end
            else begin
                next_state = START;
            end
        end

        DATA: begin
            if (clk_count == CLKS_PER_BIT-1) begin
                if (bit_index == 7)
                    next_state = STOP;
                else
                    next_state = DATA;
            end
            else begin
                next_state = DATA;
            end
        end

        STOP: begin
            if (clk_count == CLKS_PER_BIT-1)
                next_state = IDLE;
            else
                next_state = STOP;
        end

        default:
            next_state = IDLE;

    endcase
end

// Datapath
always @(posedge clk) begin

    if (!resetn) begin
        clk_count  <= 16'd0;
        bit_index  <= 3'd0;
        data_valid <= 1'b0;
        data_out   <= 8'd0;
        rx_shift   <= 8'd0;
    end
    else begin

        case (state)

            IDLE: begin
                clk_count  <= 16'd0;
                bit_index  <= 3'd0;
                data_valid <= 1'b0;
            end

            START: begin
                if (clk_count == (CLKS_PER_BIT/2)-1)
                    clk_count <= 16'd0;
                else
                    clk_count <= clk_count + 16'd1;

                data_valid <= 1'b0;
            end

            DATA: begin
                if (clk_count == CLKS_PER_BIT-1) begin
                    clk_count           <= 16'd0;
                    rx_shift[bit_index] <= rx_sync_2;

                    if (bit_index < 7)
                        bit_index <= bit_index + 3'd1;
                    else
                        bit_index <= 3'd0;
                end
                else begin
                    clk_count <= clk_count + 16'd1;
                end

                data_valid <= 1'b0;
            end

            STOP: begin
                if (clk_count == CLKS_PER_BIT-1) begin
                    clk_count <= 16'd0;

                    if (rx_sync_2 == 1'b1) begin
                        data_out   <= rx_shift;
                        data_valid <= 1'b1;
                    end
                    else begin
                        data_valid <= 1'b0;
                    end
                end
                else begin
                    clk_count  <= clk_count + 16'd1;
                    data_valid <= 1'b0;
                end
            end

            default: begin
                clk_count  <= 16'd0;
                data_valid <= 1'b0;
            end

        endcase
    end
end

endmodule