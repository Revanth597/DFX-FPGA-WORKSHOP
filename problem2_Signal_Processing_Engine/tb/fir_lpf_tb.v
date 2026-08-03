`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.08.2026 12:48:58
// Design Name: 
// Module Name: fir_lpf_tb
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


module fir_lpf_tb;

    reg clk;
    reg rst;

    reg signed [15:0] sample_in;
    reg               sample_valid;

    wire signed [15:0] sample_out;
    wire               output_valid;


    // FIR DUT
    fir_lpf DUT (
        .clk(clk),
        .rst(rst),
        .sample_in(sample_in),
        .sample_valid(sample_valid),
        .sample_out(sample_out),
        .output_valid(output_valid)
    );


    // 100 MHz clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // Send one input sample
    task send_sample;
        input signed [15:0] value;
        begin
            @(negedge clk);
            sample_in    = value;
            sample_valid = 1'b1;

            @(negedge clk);
            sample_valid = 1'b0;
        end
    endtask


    initial begin

        rst          = 1'b1;
        sample_in    = 16'sd0;
        sample_valid = 1'b0;

        #100;

        @(negedge clk);
        rst = 1'b0;


        // Alternating signal makes filtering easy to observe
        send_sample(16'sd0);
        send_sample(16'sd100);
        send_sample(16'sd0);
        send_sample(16'sd100);
        send_sample(16'sd0);
        send_sample(16'sd100);
        send_sample(16'sd0);
        send_sample(16'sd100);


        #100;

        $finish;
    end


    // Print FIR results
    always @(posedge clk) begin
        if (output_valid)
            $display(
                "Time = %0t | FIR Output = %0d",
                $time,
                sample_out
            );
    end

endmodule
