`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.08.2026 12:44:52
// Design Name: 
// Module Name: moving_average_tb
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


module moving_average_tb;

    reg clk;
    reg rst;

    reg signed [15:0] sample_in;
    reg               sample_valid;

    wire signed [15:0] sample_out;
    wire               output_valid;


    // DUT
    moving_average DUT (
        .clk(clk),
        .rst(rst),
        .sample_in(sample_in),
        .sample_valid(sample_valid),
        .sample_out(sample_out),
        .output_valid(output_valid)
    );


    // 100 MHz clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    // Send one sample
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


        // Input sequence
        send_sample(16'sd10);
        send_sample(16'sd20);
        send_sample(16'sd30);
        send_sample(16'sd40);
        send_sample(16'sd50);
        send_sample(16'sd60);
        send_sample(16'sd70);
        send_sample(16'sd80);


        #100;

        $finish;
    end


    // Print valid results
    always @(posedge clk) begin
        if (output_valid)
            $display(
                "Time = %0t | Moving Average = %0d",
                $time,
                sample_out
            );
    end

endmodule
