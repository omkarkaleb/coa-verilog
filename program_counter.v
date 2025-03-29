module program_counter(
    input wire clk,
    input wire reset,
    input wire [15:0] pc_in,
    output reg [15:0] pc_out
);

    // On reset, PC starts at 0
    // On rising edge, PC takes the value of pc_in
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 16'b0;
        else
            pc_out <= pc_in;
    end

endmodule