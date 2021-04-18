`default_nettype none
module scope_test (
    input wire clk_i,
    output wire tmds_p_o,
    output wire tmds_n_o
);

// Begin with a reset
reg reset = 1;
always @(posedge clk_i)
    reset <= 0;

// Generate a compliance pattern for testing on the scope
wire fifo_full;
wire [9:0] pattern;
wire write_pattern = !fifo_full;
lfsr compliance_pattern_generator(
    .clk_i(clk_i),
    .rst_i(reset),
    .next_i(write_pattern),
    .output_o(pattern)
);

// Serialize and buffer the pattern
tmds #(
    .OBUFDS_IOSTANDARD("LVDS_25"), // Set to LVDS_25 so that I can use the 50 ohm termination to ground on my scope
    .CLK_I_FREQ(100000000),
    .CLK_I_MULT(15),
    .CLK_I_DIV(1),
    .VCO_DIV(12)
) hdmi_buf (
    .clk_i(clk_i),
    .rst_i(reset),
    .symbol_fifo_full_o(fifo_full),
    .write_symbol_i(write_pattern),
    .symbol_i(pattern),
    .tmds_p_o(tmds_p_o),
    .tmds_n_o(tmds_n_o)
);

endmodule
`default_nettype wire
