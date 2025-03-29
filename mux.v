module mux #(parameter WIDTH = 16) (
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    input wire select,
    output wire [WIDTH-1:0] out
);

    // Select a if select == 0, b if select == 1
    assign out = select ? b : a;

endmodule