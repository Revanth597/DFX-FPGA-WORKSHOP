`timescale 1ns / 1ps

module decision_engine_tb;

    reg  [31:0] operand_a;
    reg  [31:0] operand_b;
    reg  [1:0]  operation;
    wire [31:0] result;

    decision_engine uut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .operation(operation),
        .result(result)
    );

    initial begin

        operand_a = 0;
        operand_b = 0;
        operation = 2'b00;
        #20;

        // Maximum of 20 and 10 = 20
        operand_a = 20;
        operand_b = 10;
        operation = 2'b00;
        #20;

        // Minimum of 20 and 10 = 10
        operation = 2'b01;
        #20;

        // Equality: 25 == 25
        operand_a = 25;
        operand_b = 25;
        operation = 2'b10;
        #20;

        // Equality: 25 != 30
        operand_a = 25;
        operand_b = 30;
        operation = 2'b10;
        #20;

        // Absolute difference: |50 - 20| = 30
        operand_a = 50;
        operand_b = 20;
        operation = 2'b11;
        #20;

        // Absolute difference: |20 - 50| = 30
        operand_a = 20;
        operand_b = 50;
        operation = 2'b11;
        #20;

        $finish;

    end

endmodule