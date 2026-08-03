`timescale 1ns / 1ps

module integer_logic_tb;

    reg  [31:0] operand_a;
    reg  [31:0] operand_b;
    reg  [1:0]  operation;
    wire [31:0] result;

    integer_logic uut (
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

        // AND: 12 & 10 = 8
        operand_a = 12;
        operand_b = 10;
        operation = 2'b00;
        #20;

        // OR: 12 | 10 = 14
        operation = 2'b01;
        #20;

        // XOR: 12 ^ 10 = 6
        operation = 2'b10;
        #20;

        // Shift operation
        operand_a = 3;
        operand_b = 2;
        operation = 2'b11;
        #20;

        // Shift operation
        operand_a = 5;
        operand_b = 3;
        operation = 2'b11;
        #20;

        $finish;

    end

endmodule