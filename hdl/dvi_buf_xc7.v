`default_nettype none

module dvi_buffer_xc7 #(
    parameter OBUFDS_IOSTANDARD = "TMDS_33"
) (
    input wire clk_parallel_i,
    input wire clk_serial_i,
    input wire clocks_stable_i,

    input  wire [9:0] symbol_red_i,
    input  wire [9:0] symbol_green_i,
    input  wire [9:0] symbol_blue_i,

    output wire tmds_red_p_o,
    output wire tmds_red_n_o,
    output wire tmds_green_p_o,
    output wire tmds_green_n_o,
    output wire tmds_blue_p_o,
    output wire tmds_blue_n_o,
    output wire tmds_clk_p_o,
    output wire tmds_clk_n_o
);

wire [3*10-1:0] symbol_i = {symbol_red_i, symbol_green_i, symbol_blue_i};

wire [2:0] tmds_p_o, tmds_n_o;
assign {tmds_red_p_o, tmds_green_p_o, tmds_blue_p_o} = tmds_p_o;
assign {tmds_red_n_o, tmds_green_n_o, tmds_blue_n_o} = tmds_n_o;

/*
 * Reset logic
 *  OSERDES reqs:
 *      RESET may be asserted asynchronously, and must be deasserted synchronously with CLKDIV. RESET should only be
 *      deasserted once both clocks are stable.
 */      
wire clocks_stable_sync;
reset_synchronizer #(
    .COUNT(10)
) pll_locked_synchronizer (
    .clk_i(clk_parallel_i),
    .reset_n_i(clocks_stable_i),
    .reset_n_o(clocks_stable_sync)
);
wire reset_oserdes = ~clocks_stable_sync;

// Generate an oserdes module for each color channel
genvar i;
generate for (i = 0; i < 3; i = i + 1) begin
    wire serdes_serial_out;
    wire [1:0] shift;

    /*
     * Serialize the 10 bit symbol received from the OUT_FIFO. The serial clock is 5 times faster than the parallel clock,
     * with data being clocked out on both the rising and falling edge of the serial clock.  Two cascaded OSERDES modules
     * are needed for 10 bit mode.
     */
    OSERDESE2 #(
        .DATA_RATE_OQ("DDR"), // DDR, SDR
        .DATA_RATE_TQ("SDR"), // DDR, BUF, SDR
        .DATA_WIDTH(10), // Parallel data width (2-8,10,14)
        .INIT_OQ(1'b0), // Initial value of OQ output (1'b0,1'b1)
        .INIT_TQ(1'b0), // Initial value of TQ output (1'b0,1'b1)
        .SERDES_MODE("MASTER"), // MASTER, SLAVE
        .SRVAL_OQ(1'b0), // OQ output value when SR is used (1'b0,1'b1)
        .SRVAL_TQ(1'b0), // TQ output value when SR is used (1'b0,1'b1)
        .TBYTE_CTL("FALSE"), // Enable tristate byte operation (FALSE, TRUE)
        .TBYTE_SRC("FALSE"), // Tristate byte source (FALSE, TRUE)
        .TRISTATE_WIDTH(1) // 3-state converter width (1,4)
    ) serializer_bottom (
        .OFB(), // 1-bit output: Feedback path for data
        .OQ(serdes_serial_out), // 1-bit output: Data path output

        // SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
        .SHIFTOUT1(),
        .SHIFTOUT2(),

        .TBYTEOUT(), // 1-bit output: Byte group tristate
        .TFB(), // 1-bit output: 3-state control
        .TQ(), // 1-bit output: 3-state control

        .CLK(clk_serial_i), // 1-bit input: High speed clock
        .CLKDIV(clk_parallel_i), // 1-bit input: Divided clock

        // D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
        .D1(symbol_i[i*10 + 0]),
        .D2(symbol_i[i*10 + 1]),
        .D3(symbol_i[i*10 + 2]),
        .D4(symbol_i[i*10 + 3]),
        .D5(symbol_i[i*10 + 4]),
        .D6(symbol_i[i*10 + 5]),
        .D7(symbol_i[i*10 + 6]),
        .D8(symbol_i[i*10 + 7]),

        .OCE(1'b1), // 1-bit input: Output data clock enable
        .RST(reset_oserdes), // 1-bit input: Reset

        // SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
        .SHIFTIN1(shift[0]),
        .SHIFTIN2(shift[1]),

        // T1 - T4: 1-bit (each) input: Parallel 3-state inputs
        .T1(1'b0),
        .T2(1'b0),
        .T3(1'b0),
        .T4(1'b0),

        .TBYTEIN(1'b0), // 1-bit input: Byte group tristate
        .TCE(1'b0) // 1-bit input: 3-state clock enable
    );

    OSERDESE2 #(
        .DATA_RATE_OQ("DDR"), // DDR, SDR
        .DATA_RATE_TQ("SDR"), // DDR, BUF, SDR
        .DATA_WIDTH(10), // Parallel data width (2-8,10,14)
        .INIT_OQ(1'b0), // Initial value of OQ output (1'b0,1'b1)
        .INIT_TQ(1'b0), // Initial value of TQ output (1'b0,1'b1)
        .SERDES_MODE("SLAVE"), // MASTER, SLAVE
        .SRVAL_OQ(1'b0), // OQ output value when SR is used (1'b0,1'b1)
        .SRVAL_TQ(1'b0), // TQ output value when SR is used (1'b0,1'b1)
        .TBYTE_CTL("FALSE"), // Enable tristate byte operation (FALSE, TRUE)
        .TBYTE_SRC("FALSE"), // Tristate byte source (FALSE, TRUE)
        .TRISTATE_WIDTH(1) // 3-state converter width (1,4)
    ) serializer_top (
        .OFB(), // 1-bit output: Feedback path for data
        .OQ(), // 1-bit output: Data path output

        // SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
        .SHIFTOUT1(shift[0]),
        .SHIFTOUT2(shift[1]),

        .TBYTEOUT(), // 1-bit output: Byte group tristate
        .TFB(), // 1-bit output: 3-state control
        .TQ(), // 1-bit output: 3-state control

        .CLK(clk_serial_i), // 1-bit input: High speed clock
        .CLKDIV(clk_parallel_i), // 1-bit input: Divided clock

        // D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
        .D1(1'b0),
        .D2(1'b0),
        .D3(symbol_i[i*10 + 8]),
        .D4(symbol_i[i*10 + 9]),
        .D5(1'b0),
        .D6(1'b0),
        .D7(1'b0),
        .D8(1'b0),

        .OCE(1'b0), // 1-bit input: Output data clock enable
        .RST(reset_oserdes), // 1-bit input: Reset

        // SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
        .SHIFTIN1(1'b0),
        .SHIFTIN2(1'b0),

        // T1 - T4: 1-bit (each) input: Parallel 3-state inputs
        .T1(1'b0),
        .T2(1'b0),
        .T3(1'b0),
        .T4(1'b0),

        .TBYTEIN(1'b0), // 1-bit input: Byte group tristate
        .TCE(1'b0) // 1-bit input: 3-state clock enable
    );

    /*
     * Turn the single-ended signal into a differential signal and buffer it so it can be sent off-chip.
     */
    OBUFDS #(
        //.SLEW("FAST"),
        .IOSTANDARD(OBUFDS_IOSTANDARD)
    ) tmds_diff_pair_out (
        .I(serdes_serial_out),
        .O(tmds_p_o[i]),
        .OB(tmds_n_o[i])
    );

end endgenerate

/*
 * Generate the clock signal directly from the parallel clock
 */
OBUFDS #(
    //.SLEW("FAST"),
    .IOSTANDARD(OBUFDS_IOSTANDARD)
) tmds_diff_pair_out (
    .I(clk_parallel_i),
    .O(tmds_clk_p_o),
    .OB(tmds_clk_n_o)
);
endmodule

`default_nettype wire
