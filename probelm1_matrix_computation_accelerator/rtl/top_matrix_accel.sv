//////////////////////////////////////////////////////////////////////////////////
// Company: DFX-FPGA-WORKSHOP
// Engineer: Revanth A H
// Create Date: 01.08.2026 11:22:05
// Design Name: 
// Module Name: top_matrix_accel
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

module top_matrix_accel (
    input  wire       clk100mhz,
    input  wire       rst_btn,
    input  wire       uart_rxd,
    output wire       uart_txd,
    output reg  [2:0] led_mode
);

    // ------------------------------------------------------------
    // UART RX Signals
    // ------------------------------------------------------------
    wire [7:0] rx_data;
    wire       rx_valid;

    // ------------------------------------------------------------
    // UART TX Signals
    // ------------------------------------------------------------
    reg  [7:0] tx_data;
    reg        tx_start = 0;
    wire       tx_busy;

    // ------------------------------------------------------------
    // UART RX
    // ------------------------------------------------------------
    uart_rx #(
        .CLK_FREQ(100_000_000),
        .BAUD_RATE(115200)
    ) u_rx (
        .clk(clk100mhz),
        .rst(rst_btn),
        .rx(uart_rxd),
        .data_out(rx_data),
        .data_valid(rx_valid)
    );

    // ------------------------------------------------------------
    // UART TX
    // ------------------------------------------------------------
    uart_tx #(
        .CLK_FREQ(100_000_000),
        .BAUD_RATE(115200)
    ) u_tx (
        .clk(clk100mhz),
        .rst(rst_btn),
        .data_in(tx_data),
        .start(tx_start),
        .tx(uart_txd),
        .busy(tx_busy)
    );

    // ------------------------------------------------------------
    // Matrix Storage
    // ------------------------------------------------------------

    reg [7:0] mode_reg = 0;

    // 25 elements x 16 bits = 400 bits
    reg signed [399:0] mat_A;
    reg signed [399:0] mat_B;

    // 25 elements x 32 bits = 800 bits
    reg signed [799:0] mat_C;

    wire signed [799:0] add_out;
    wire signed [799:0] mult_out;
    wire signed [799:0] tr_out;

    // Counter for 25 matrix elements
    reg [5:0] counter;

    // Counter for RX/TX bytes
    reg [7:0] byte_count;

    // Calculation start pulse
    reg start_calc = 0;

    // Done signals from submodules
    wire add_done;
    wire mult_done;
    wire tr_done;

    // NEW: Latches the selected done signal
    reg calc_done_latched;


    // ------------------------------------------------------------
    // Arithmetic Submodules
    // ------------------------------------------------------------

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


    // ------------------------------------------------------------
    // FSM States
    // ------------------------------------------------------------

    typedef enum logic [2:0] {
        ST_IDLE,
        ST_RX_BYTES,
        ST_COMPUTE,
        ST_TX_BYTES,
        ST_TX_WAIT
    } state_t;

    state_t state, next_state;


    // ------------------------------------------------------------
    // State Register
    // ------------------------------------------------------------

    always @(posedge clk100mhz) begin
        if (!rst_btn) begin
            state <= ST_IDLE;
        end
        else begin
            state <= next_state;
        end
    end


    // ------------------------------------------------------------
    // Next-State Logic
    // ------------------------------------------------------------

    always @(*) begin

        next_state = state;

        case (state)

            // ----------------------------------------------------
            // IDLE
            // First received byte is the operation mode
            // ----------------------------------------------------
            ST_IDLE: begin
                if (rx_valid)
                    next_state = ST_RX_BYTES;
                else
                    next_state = ST_IDLE;
            end


            // ----------------------------------------------------
            // Receive 100 bytes
            // 50 bytes = Matrix A
            // 50 bytes = Matrix B
            // ----------------------------------------------------
            ST_RX_BYTES: begin

                if (rx_valid && byte_count == 99)
                    next_state = ST_COMPUTE;
                else
                    next_state = ST_RX_BYTES;

            end


            // ----------------------------------------------------
            // Wait for selected calculation to complete
            // ----------------------------------------------------
            ST_COMPUTE: begin

                // Wait until the selected done signal has been
                // latched AND all 25 results have been copied
                if (calc_done_latched && counter == 24)
                    next_state = ST_TX_BYTES;
                else
                    next_state = ST_COMPUTE;

            end


            // ----------------------------------------------------
            // Start sending one byte
            // ----------------------------------------------------
            ST_TX_BYTES: begin

                if (!tx_busy && !tx_start)
                    next_state = ST_TX_WAIT;
                else
                    next_state = ST_TX_BYTES;

            end


            // ----------------------------------------------------
            // Wait until UART finishes current byte
            // ----------------------------------------------------
            ST_TX_WAIT: begin

                if (!tx_busy) begin

                    if (byte_count == 99)
                        next_state = ST_IDLE;
                    else
                        next_state = ST_TX_BYTES;

                end
                else begin
                    next_state = ST_TX_WAIT;
                end

            end


            default: begin
                next_state = ST_IDLE;
            end

        endcase

    end


    // ------------------------------------------------------------
    // Datapath and Control Logic
    // ------------------------------------------------------------

    always @(posedge clk100mhz) begin

        if (!rst_btn) begin

            byte_count       <= 0;
            tx_start         <= 0;
            start_calc       <= 0;
            led_mode         <= 3'b000;
            counter          <= 0;
            mode_reg         <= 0;
            tx_data          <= 0;
            mat_A            <= 0;
            mat_B            <= 0;
            mat_C            <= 0;

        end
        else begin

            // Default: these are one-clock pulses
            tx_start   <= 1'b0;
            start_calc <= 1'b0;


            // ====================================================
            // LATCH THE SELECTED DONE SIGNAL
            // ====================================================

            if (!calc_done_latched) begin

                if ((mode_reg == 8'h01 && add_done) ||
                    (mode_reg == 8'h02 && mult_done) ||
                    (mode_reg == 8'h03 && tr_done)) begin

                    calc_done_latched <= 1'b1;

                end

            end


            case (state)

                // =================================================
                // IDLE
                // =================================================
                ST_IDLE: begin

                    byte_count <= 0;
                    counter    <= 0;

                    // Clear done latch for a new operation
                    calc_done_latched <= 1'b0;

                    if (rx_valid) begin

                        // First UART byte = mode
                        mode_reg <= rx_data;

                        case (rx_data)

                            8'h01: led_mode <= 3'b001; // ADD
                            8'h02: led_mode <= 3'b010; // MULT
                            8'h03: led_mode <= 3'b100; // TRANSPOSE

                            default: led_mode <= 3'b000;

                        endcase

                    end

                end


                // =================================================
                // RECEIVE MATRIX A AND MATRIX B
                // =================================================
                ST_RX_BYTES: begin

                    if (rx_valid) begin

                        // -----------------------------------------
                        // Matrix A = bytes 0 to 49
                        // -----------------------------------------
                        if (byte_count < 50) begin

                            if (byte_count[0] == 1'b0) begin

                                // Lower 8 bits
                                mat_A[(byte_count >> 1)*16 +: 8]
                                    <= rx_data;

                            end
                            else begin

                                // Upper 8 bits
                                mat_A[(byte_count >> 1)*16 + 8 +: 8]
                                    <= rx_data;

                            end

                        end


                        // -----------------------------------------
                        // Matrix B = bytes 50 to 99
                        // -----------------------------------------
                        else begin

                            if (byte_count[0] == 1'b0) begin

                                // Lower 8 bits
                                mat_B[((byte_count - 50) >> 1)*16 +: 8]
                                    <= rx_data;

                            end
                            else begin

                                // Upper 8 bits
                                mat_B[((byte_count - 50) >> 1)*16 + 8 +: 8]
                                    <= rx_data;

                            end

                        end


                        // -----------------------------------------
                        // 100th byte received
                        // -----------------------------------------
                        if (byte_count == 99) begin

                            // Pulse calculation start
                            start_calc <= 1'b1;

                            // Prepare for result-copy phase
                            counter <= 0;

                            // Clear old done latch before new operation
                            calc_done_latched <= 1'b0;

                            // Reset byte count for TX later
                            byte_count <= 0;

                        end
                        else begin

                            byte_count <= byte_count + 1'b1;

                        end

                    end

                end


                // =================================================
                // COMPUTE
                // =================================================
                ST_COMPUTE: begin

                    // IMPORTANT:
                    // Only start copying results AFTER the selected
                    // calculation done signal has been latched.
                    if (calc_done_latched) begin

                        case (mode_reg)

                            8'h01:
                                mat_C[counter*32 +: 32]
                                    <= add_out[counter*32 +: 32];

                            8'h02:
                                mat_C[counter*32 +: 32]
                                    <= mult_out[counter*32 +: 32];

                            8'h03:
                                mat_C[counter*32 +: 32]
                                    <= tr_out[counter*32 +: 32];

                            default:
                                mat_C[counter*32 +: 32]
                                    <= add_out[counter*32 +: 32];

                        endcase


                        // Copy all 25 x 32-bit elements
                        if (counter == 24) begin

                            counter    <= 0;
                            byte_count <= 0;

                        end
                        else begin

                            counter <= counter + 1'b1;

                        end

                    end

                end


                // =================================================
                // TRANSMIT ONE BYTE
                // =================================================
                ST_TX_BYTES: begin

                    if (!tx_busy && !tx_start) begin

                        tx_data <= mat_C[byte_count*8 +: 8];

                        // One-clock pulse
                        tx_start <= 1'b1;

                    end

                end


                // =================================================
                // WAIT FOR UART TO FINISH
                // =================================================
                ST_TX_WAIT: begin

                    if (!tx_busy) begin

                        if (byte_count != 99) begin

                            byte_count <= byte_count + 1'b1;

                        end

                    end

                end


                default: begin

                    // Nothing required here

                end

            endcase

        end

    end

endmodule