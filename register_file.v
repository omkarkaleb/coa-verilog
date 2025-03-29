module register_file(
    input wire clk,
    input wire reset,
    input wire reg_write,
    input wire [3:0] read_reg1,
    input wire [3:0] read_reg2,
    input wire [3:0] write_reg,
    input wire [15:0] write_data,
    output wire [15:0] read_data1,
    output wire [15:0] read_data2
);

    // 16 registers of 16 bits each
    reg [15:0] registers [0:15];
    integer i;

    // Read operations - asynchronous
    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];

    // Write operation - synchronous
    always @(posedge clk) begin
        if (reset) begin
            // Reset all registers to 0
            for (i = 0; i < 16; i = i + 1) begin
                registers[i] <= 16'h0000;
            end
        end
        else if (reg_write && write_reg != 0) begin
            registers[write_reg] <= write_data;
            // For debugging
            $display("Register write: R%d = %d", write_reg, write_data);
        end
    end

    // Initialize all registers to 0
    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            registers[i] = 16'h0000;
        end
        $display("Registers initialized to 0");
    end

endmodule