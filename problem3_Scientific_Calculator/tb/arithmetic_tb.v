`timescale 1ns / 1ps

module arithmetic_tb;

    reg  [31:0] operand_a;
    reg  [31:0] operand_b;
    reg  [1:0]  operation;
    wire [31:0] result;

    arithmetic uut (
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

        // Addition: 20 + 10 = 30
        operand_a = 20;
        operand_b = 10;
        operation = 2'b00;
        #20;

        // Subtraction: 20 - 10 = 10
        operation = 2'b01;
        #20;

        // Multiplication: 20 * 10 = 200
        operation = 2'b10;
        #20;

        // Division: 20 / 10 = 2
        operation = 2'b11;
        #20;

        // Multiplication: 12 * 5 = 60
        operand_a = 12;
        operand_b = 5;
        operation = 2'b10;
        #20;

        // Division by zero
        operand_a = 100;
        operand_b = 0;
        operation = 2'b11;
        #20;

        $finish;

    end

endmodule