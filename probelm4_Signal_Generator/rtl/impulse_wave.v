`timescale 1ns / 1ps


module impulse_wave (
    input  wire       clk,
    input  wire       rst,
    output reg  [7:0] wave_out
);

    reg [27:0] counter;

    always @(posedge clk) begin
        if (rst) begin
            counter  <= 0;
            wave_out <= 8'h00;
        end
        else begin

            // 100 MHz clock
            // Generate an impulse approximately every 2 seconds
            if (counter == 28'd199_999_999) begin
                counter  <= 0;
                wave_out <= 8'hFF;
            end

            // Keep LEDs ON for approximately 200 ms
            else if (counter < 28'd20_000_000) begin
                counter  <= counter + 1'b1;
                wave_out <= 8'hFF;
            end

            else begin
                counter  <= counter + 1'b1;
                wave_out <= 8'h00;
            end

        end
    end

endmodule