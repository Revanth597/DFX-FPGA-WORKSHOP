module uart_rx #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 115200
)(
    input  wire clk,
    input  wire rst,
    input  wire rx,
    output reg  [7:0] data_out,
    output reg  data_valid
);
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    localparam IDLE=0, START=1, DATA=2, STOP=3;
    reg [2:0] state = IDLE;
    reg [15:0] clk_count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] rx_shift = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            data_valid <= 0;
            clk_count <= 0;
            bit_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    data_valid <= 0;
                    clk_count <= 0;
                    bit_index <= 0;
                    if (rx == 0) state <= START;  // start bit detected (line goes low)
                end
                START: begin
                    // wait to sample in the middle of the start bit
                    if (clk_count == (CLKS_PER_BIT/2)) begin
                        if (rx == 0) begin
                            clk_count <= 0;
                            state <= DATA;
                        end else state <= IDLE; // false start
                    end else clk_count <= clk_count + 1;
                end
                DATA: begin
                    if (clk_count < CLKS_PER_BIT-1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        rx_shift[bit_index] <= rx;
                        if (bit_index < 7) bit_index <= bit_index + 1;
                        else state <= STOP;
                    end
                end
                STOP: begin
                    if (clk_count < CLKS_PER_BIT-1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        data_out   <= rx_shift;
                        data_valid <= 1;
                        clk_count  <= 0;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule