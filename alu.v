module alu(
    input wire [15:0] a,
    input wire [15:0] b,
    input wire [2:0] alu_control,
    output reg [15:0] result,
    output wire zero
);

    // ALU Control signals
    // 000: ADD
    // 001: SUB
    // 010: SLL (shift left logical)
    // 011: AND

    // Zero flag
    assign zero = (result == 16'b0);

    always @(*) begin
        case (alu_control)
            3'b000: begin 
                result = a + b;           // ADD
                $display("ALU: a=%d, b=%d, result=%d (ADD)", a, b, a+b);
            end
            3'b001: begin
                result = a - b;           // SUB
                $display("ALU: a=%d, b=%d, result=%d (SUB)", a, b, a-b);
            end
            3'b010: begin
                result = a << b;          // SLL
                $display("ALU: a=%d, b=%d, result=%d (SLL)", a, b, a<<b);
            end
            3'b011: begin
                result = a & b;           // AND
                $display("ALU: a=%d, b=%d, result=%d (AND)", a, b, a&b);
            end
            default: begin
                result = a + b;          // Default to ADD
                $display("ALU: a=%d, b=%d, result=%d (Default ADD)", a, b, a+b);
            end
        endcase
    end

endmodule