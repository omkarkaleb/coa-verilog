module data_memory(
    input wire clk,
    input wire reset,
    input wire mem_read,
    input wire mem_write,
    input wire [15:0] address,
    input wire [15:0] write_data,
    output wire [15:0] read_data
);

    // Memory array (64 memory locations)
    reg [15:0] memory [0:63];
    integer i;

    // Read operation - asynchronous
    assign read_data = mem_read ? memory[address >> 1] : 16'b0;

    // Write operation - synchronous
    always @(posedge clk) begin
        if (mem_write)
            memory[address >> 1] <= write_data;
    end

    // Initialize memory with test data
    initial begin
        // Clear memory
        for (i = 0; i < 64; i = i + 1) begin
            memory[i] = 16'h0000;
        end

        // Add test data at known locations
        memory[0] = 16'd5;   // Value 5 at address 0 (first lw instruction)
        memory[1] = 16'd7;   // Value 7 at address 2 (second lw instruction)
        
        // Print data memory initialization for debugging
        $display("Data memory initialized: memory[0]=%d, memory[1]=%d", 
                  memory[0], memory[1]);
    end

endmodule