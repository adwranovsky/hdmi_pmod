`default_nettype none
module lfsr #(
    parameter WIDTH = 10,
    parameter SEED  = 10'h2aa,
    parameter TAPS  = 10'h2C2
) (
    input wire clk_i,
    input wire rst_i,
    input wire next_i,
    output wire [WIDTH-1:0] output_o
);

wire input_bit;
reg [WIDTH-1:0] shift_reg = SEED;
always @(posedge clk_i) begin
    if (rst_i)
        shift_reg <= SEED;
    else if (next_i)
        shift_reg <= {shift_reg[WIDTH-2:0], input_bit};
    else
        shift_reg <= shift_reg;
end

assign input_bit = ^(shift_reg & TAPS);

assign output_o = shift_reg;

endmodule
`default_nettype wire
