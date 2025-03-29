module cpu(
    input wire clk,
    input wire reset,
    output wire [15:0] pc_out,
    output wire [15:0] instruction_out,
    output wire [15:0] alu_result_out,
    output wire [15:0] data_mem_read_out
);

    // PC signals
    wire [15:0] pc;
    wire [15:0] pc_next;
    wire [15:0] pc_plus_2;
    wire [15:0] jump_target;

    // Instruction and its fields
    wire [15:0] instruction;
    wire [3:0] opcode;
    wire [3:0] rd;     // destination register for R-type
    wire [3:0] rs;     // source register 1
    wire [3:0] rt;     // source register 2 for R-type
    wire [3:0] funct;
    wire [3:0] imm;
    wire [11:0] jump_addr;

    // Register file signals
    wire [15:0] reg_write_data;
    wire [15:0] reg_read_data1;
    wire [15:0] reg_read_data2;
    wire [15:0] store_data;    // NEW: For SW instruction data

    // ALU signals
    wire [15:0] alu_input2;
    wire [15:0] alu_result;
    wire alu_zero;

    // Data memory signals
    wire [15:0] mem_read_data;

    // Control signals
    wire reg_dst, jump, branch, mem_read, mem_to_reg;
    wire [2:0] alu_op;
    wire mem_write, alu_src, reg_write;

    // Sign extension
    wire [15:0] sign_extended_imm;

    // Expose outputs for testbench
    assign pc_out = pc;
    assign instruction_out = instruction;
    assign alu_result_out = alu_result;
    assign data_mem_read_out = mem_read_data;

    // Instruction decode
    assign opcode = instruction[15:12];
    assign rd = instruction[11:8];    // Destination register (for R-type) / Source register (for SW)
    assign rs = instruction[7:4];     // First source register / Base address register
    assign rt = instruction[3:0];     // Second source register / Function code / Immediate
    assign funct = instruction[3:0];  // Function code (for R-type)
    assign imm = instruction[3:0];    // Immediate value
    assign jump_addr = instruction[11:0];  // Jump address

    // Program counter
    program_counter PC(
        .clk(clk),
        .reset(reset),
        .pc_in(pc_next),
        .pc_out(pc)
    );

    // PC + 2 (next instruction)
    assign pc_plus_2 = pc + 16'd2;

    // Jump target calculation
    assign jump_target = {pc[15:12], jump_addr, 1'b0};

    // PC next value
    assign pc_next = jump ? jump_target : pc_plus_2;

    // Instruction memory
    instruction_memory IMEM(
        .address(pc),
        .instruction(instruction)
    );

    // Control unit
    control_unit CTRL(
        .opcode(opcode),
        .function_code(funct),
        .reg_dst(reg_dst),
        .jump(jump),
        .branch(branch),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write)
    );

    // NEW: Additional register read for SW instruction
    wire [3:0] sw_reg = rd;  // For SW, the source register is in the rd field
    
    // Register file with additional read port for SW
    register_file REGS(
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .read_reg1(rs),
        .read_reg2(rt),
        .write_reg(rd),
        .write_data(reg_write_data),
        .read_data1(reg_read_data1),
        .read_data2(reg_read_data2)
    );

    // For SW instructions, we need to read from rd (not rt)
    // This works because for our specific ISA, we have sw rd, offset(rs)
    // which stores the value in rd at address rs+offset
    wire [15:0] sw_data;
    assign sw_data = (opcode == 4'b0010) ? REGS.registers[rd] : 16'b0;

    // Sign extension
    sign_extension SIGN_EXT(
        .immediate(imm),
        .sign_extended_immediate(sign_extended_imm)
    );

    // ALU input 2 multiplexer
    assign alu_input2 = alu_src ? sign_extended_imm : reg_read_data2;

    // ALU
    alu ALU(
        .a(reg_read_data1),
        .b(alu_input2),
        .alu_control(alu_op),
        .result(alu_result),
        .zero(alu_zero)
    );

    // Data to write to memory - use rd register value for SW
    wire [15:0] mem_write_data;
    assign mem_write_data = (opcode == 4'b0010) ? sw_data : reg_read_data2;

    // Data memory
    data_memory DMEM(
        .clk(clk),
        .reset(reset),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_result),
        .write_data(mem_write_data),  // Use rd value for SW
        .read_data(mem_read_data)
    );

    // Register write data multiplexer
    assign reg_write_data = mem_to_reg ? mem_read_data : alu_result;

    // Debug
    always @(posedge clk) begin
        $display("Debug: PC=%h, Instr=%h, OpCode=%b, RS=%b, RT=%b, RD=%b", 
                 pc, instruction, opcode, rs, rt, rd);
                 
        // Add special debug for SW instructions
        if (opcode == 4'b0010) begin
            $display("Debug: SW instruction - storing value %d from R%d to address %d", 
                     sw_data, rd, alu_result);
        end
                 
        $display("Debug: REG1=%d, REG2=%d, ALU_Result=%d, reg_write=%b, reg_write_data=%d", 
                 reg_read_data1, reg_read_data2, alu_result, reg_write, reg_write_data);
        
        // For R-type instructions
        if (opcode == 4'b0000) begin
            $display("R-TYPE: rd=%d, rs=%d, rt=%d, funct=%b", rd, rs, rt, funct);
        end
    end

endmodule