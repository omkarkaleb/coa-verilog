module sign_extension(
    input wire [3:0] immediate,
    output wire [15:0] sign_extended_immediate
);
    // Sign extend the 4-bit immediate to 16 bits
    assign sign_extended_immediate = {{12{immediate[3]}}, immediate};
endmodule