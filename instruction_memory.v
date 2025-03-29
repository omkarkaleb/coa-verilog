module instruction_memory(
    input wire [15:0] address,
    output wire [15:0] instruction
);

    // Memory array (64 memory locations)
    reg [15:0] memory [0:63];
    integer i;
    
    // Read instruction from memory
    assign instruction = memory[address >> 1];
    
    // Initialize memory with test program
    initial begin
        // Clear memory
        for (i = 0; i < 64; i = i + 1) begin
            memory[i] = 16'h0000;
        end

        // FIXED INSTRUCTION ENCODING
        // For R-type: opcode(4) | rd(4) | rs(4) | rt/funct(4)
        // For I-type: opcode(4) | rt(4) | rs(4) | immediate(4)
        // For J-type: opcode(4) | jump address(12)
        
        // lw $1, 0($0) - Load from memory address 0 into $1
        memory[0] = 16'h1100;  // opcode=0001, rt=001, rs=000, imm=0000
        
        // lw $2, 2($0) - Load from memory address 2 into $2
        memory[1] = 16'h1202;  // opcode=0001, rt=010, rs=000, imm=0010
        
        // add $3, $1, $2 - Add $1 and $2, store in $3
        memory[2] = 16'h0312;  // opcode=0000, rd=011, rs=001, rt=010
        
        // sw $3, 4($0) - Store content of $3 into memory address 4
        // For sw instruction: opcode(0010) | rs_t(0011) | rs_s(0000) | imm(0100)
        // rs_t is both the register source and part of the address offset
        memory[3] = 16'h2304;  // opcode=0010, rt=011, rs=000, imm=0100
        
        // Jump to instruction at memory address 5 (PC = 10)
        memory[4] = 16'h6005;  // opcode=0110, address=0000 0000 0101
        
        // add $4, $3, $3 - Double the value in $3, store in $4
        memory[5] = 16'h0433;  // opcode=0000, rd=100, rs=011, rt=011
        
        // sub $5, $4, $1 - Subtract $1 from $4, store in $5
        memory[6] = 16'h0541;  // opcode=0000, rd=101, rs=100, rt=0001
    end

endmodule