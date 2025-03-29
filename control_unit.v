module control_unit(
    input wire [3:0] opcode,
    input wire [3:0] function_code,
    output reg reg_dst,
    output reg jump,
    output reg branch,
    output reg mem_read,
    output reg mem_to_reg,
    output reg [2:0] alu_op,
    output reg mem_write,
    output reg alu_src,
    output reg reg_write
);

    // Instruction opcodes as parameters
    parameter R_TYPE = 4'b0000;  // For R-type instructions
    parameter LW     = 4'b0001;  // Load word
    parameter SW     = 4'b0010;  // Store word (NEW)
    parameter JMP    = 4'b0110;  // Jump
    
    // Function codes for R-type instructions
    parameter ADD_FUNC = 4'b0000;  // Add function
    parameter SUB_FUNC = 4'b0001;  // Subtract function

    always @(*) begin
        // Default control signals
        reg_dst = 0;
        jump = 0;
        branch = 0;
        mem_read = 0;
        mem_to_reg = 0;
        alu_op = 3'b000; // Default to ADD
        mem_write = 0;
        alu_src = 0;
        reg_write = 0;
        
        case(opcode)
            R_TYPE: begin // R-type (add/sub)
                reg_write = 1;
                
                // Set ALU operation based on function code
                case(function_code)
                    SUB_FUNC: begin
                        alu_op = 3'b001; // SUB operation
                        $display("Control: R-type SUB, reg_write=%b, alu_op=%b", 
                                 reg_write, alu_op);
                    end
                    default: begin // Assume ADD for default
                        alu_op = 3'b000; // ADD operation
                        $display("Control: R-type ADD, reg_write=%b, alu_op=%b", 
                                 reg_write, alu_op);
                    end
                endcase
            end
            
            LW: begin // lw
                mem_read = 1;
                reg_write = 1;
                alu_src = 1;
                mem_to_reg = 1;
                // For debugging
                $display("Control: LW, reg_write=%b, mem_read=%b, alu_src=%b, mem_to_reg=%b", 
                          reg_write, mem_read, alu_src, mem_to_reg);
            end
            
            SW: begin // sw (NEW)
                mem_write = 1;
                alu_src = 1;
                // For debugging
                $display("Control: SW, mem_write=%b, alu_src=%b", 
                          mem_write, alu_src);
            end
            
            JMP: begin // jmp
                jump = 1;
                // For debugging
                $display("Control: JMP, jump=%b", jump);
            end
            
            default: begin
                // For debugging
                $display("Control: Unknown opcode %b", opcode);
            end
        endcase
    end

endmodule