module top_matrix_accel (
    input  wire       clk100mhz,
    input  wire       rst_btn,      // Active-high reset button
    input  wire       uart_rxd,     // UART RX pin (from PC)
    output wire       uart_txd,     // UART TX pin (to PC)
    output reg  [2:0] led_mode      // LEDs indicating selected operation mode
);

    // --- UART RX Signals ---
    wire [7:0] rx_data;
    wire       rx_valid;

    // --- UART TX Signals ---
    reg  [7:0] tx_data;
    reg        tx_start = 0;
    wire       tx_busy;

    // --- Instantiations for UART ---
    uart_rx #(.CLK_FREQ(100_000_000), .BAUD_RATE(115200)) u_rx (
        .clk(clk100mhz), .rst(rst_btn), .rx(uart_rxd),
        .data_out(rx_data), .data_valid(rx_valid)
    );

    uart_tx #(.CLK_FREQ(100_000_000), .BAUD_RATE(115200)) u_tx (
        .clk(clk100mhz), .rst(rst_btn), .data_in(tx_data),
        .start(tx_start), .tx(uart_txd), .busy(tx_busy)
    );

    // --- Storage Registers & Internal Wires ---
    reg [7:0] mode_reg = 0;
    
    // Arrays matching submodule signatures (signed 16-bit inputs, signed 32-bit outputs)
    reg  signed [15:0] mat_A [0:24];
    reg  signed [15:0] mat_B [0:24];
    reg  signed [31:0] mat_C [0:24];

    wire signed [31:0] add_out  [0:24];
    wire signed [31:0] mult_out [0:24];
    wire signed [31:0] tr_out   [0:24];

    // Submodule Control Signals
    reg  start_calc = 0;
    wire add_done, mult_done, tr_done;

    // --- Arithmetic Execution Submodules ---
    rm1_matrix_add u_add (
        .clk(clk100mhz),
        .rst(rst_btn),
        .start(start_calc),
        .matA_flat(mat_A),
        .matB_flat(mat_B),
        .matC_flat(add_out),
        .done(add_done)
    );

    rm2_matrix_mult u_mult (
        .clk(clk100mhz),
        .rst(rst_btn),
        .start(start_calc),
        .matA_flat(mat_A),
        .matB_flat(mat_B),
        .matC_flat(mult_out),
        .done(mult_done)
    );

    rm3_matrix_transpose u_tr (
        .clk(clk100mhz),
        .rst(rst_btn),
        .start(start_calc),
        .matA_flat(mat_A),
        .matB_flat(mat_B),
        .matC_flat(tr_out),
        .done(tr_done)
    );

    // --- State Machine ---
    typedef enum logic [2:0] {
        ST_IDLE,
        ST_RX_BYTES,
        ST_COMPUTE,
        ST_TX_BYTES,
        ST_TX_WAIT
    } state_t;

    state_t state = ST_IDLE;
    reg [5:0] byte_count = 0;
    integer idx;

    always @(posedge clk100mhz or posedge rst_btn) begin
        if (rst_btn) begin
            state      <= ST_IDLE;
            byte_count <= 0;
            tx_start   <= 0;
            start_calc <= 0;
            led_mode   <= 3'b000;
        end else begin
            tx_start   <= 0; // Default pulse suppression
            start_calc <= 0; // Default pulse suppression

            case (state)
                ST_IDLE: begin
                    byte_count <= 0;
                    if (rx_valid) begin
                        mode_reg <= rx_data;
                        case (rx_data)
                            8'h01: led_mode <= 3'b001; // ADD
                            8'h02: led_mode <= 3'b010; // MULT
                            8'h03: led_mode <= 3'b100; // TRANSPOSE
                            default: led_mode <= 3'b000;
                        endcase
                        state <= ST_RX_BYTES;
                    end
                end

                ST_RX_BYTES: begin
                    if (rx_valid) begin
                        if (byte_count < 25) begin
                            mat_A[byte_count] <= {8'd0, rx_data}; // Zero-extend incoming byte
                        end else begin
                            mat_B[byte_count - 25] <= {8'd0, rx_data};
                        end

                        if (byte_count == 49) begin
                            start_calc <= 1'b1; // Trigger calculation pulse
                            state      <= ST_COMPUTE;
                        end else begin
                            byte_count <= byte_count + 1'b1;
                        end
                    end
                end

                ST_COMPUTE: begin
                    // Latch result array based on mode selection
                    for (idx = 0; idx < 25; idx = idx + 1) begin
                        case (mode_reg)
                            8'h01:   mat_C[idx] <= add_out[idx];
                            8'h02:   mat_C[idx] <= mult_out[idx];
                            8'h03:   mat_C[idx] <= tr_out[idx];
                            default: mat_C[idx] <= add_out[idx];
                        endcase
                    end
                    byte_count <= 0;
                    state      <= ST_TX_BYTES;
                end

                ST_TX_BYTES: begin
                    if (!tx_busy && !tx_start) begin
                        tx_data    <= mat_C[byte_count][7:0]; // Send lower byte over UART
                        tx_start   <= 1'b1;
                        state      <= ST_TX_WAIT;
                    end
                end

                ST_TX_WAIT: begin
                    if (tx_busy) begin
                        if (byte_count == 24) begin
                            state <= ST_IDLE;
                        end else begin
                            byte_count <= byte_count + 1'b1;
                            state      <= ST_TX_BYTES;
                        end
                    end
                end

                default: state <= ST_IDLE;
            endcase
        end
    end
endmodule