`default_nettype none
module tmds (
    input wire clk_i,
    input wire rst_i,
    output wire tmds_o_p,
    output wire tmds_o_n
);

wire serdes_rst;
wire serial_out;
wire serial_clock, parallel_clock;
wire [9:0] parallel_data;
wire [1:0] shift;

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
    .OQ(serial_out), // 1-bit output: Data path output

    // SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
    .SHIFTOUT1(),
    .SHIFTOUT2(),

    .TBYTEOUT(), // 1-bit output: Byte group tristate
    .TFB(), // 1-bit output: 3-state control
    .TQ(), // 1-bit output: 3-state control

    .CLK(serial_clock), // 1-bit input: High speed clock
    .CLKDIV(parallel_clock), // 1-bit input: Divided clock

    // D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
    .D1(parallel_data[0]),
    .D2(parallel_data[1]),
    .D3(parallel_data[2]),
    .D4(parallel_data[3]),
    .D5(parallel_data[4]),
    .D6(parallel_data[5]),
    .D7(parallel_data[6]),
    .D8(parallel_data[7]),

    .OCE(1'b1), // 1-bit input: Output data clock enable
    .RST(serdes_rst), // 1-bit input: Reset

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

    .CLK(serial_clock), // 1-bit input: High speed clock
    .CLKDIV(parallel_clock), // 1-bit input: Divided clock

    // D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
    .D1(1'b0),
    .D2(1'b0),
    .D3(parallel_data[8]),
    .D4(parallel_data[9]),
    .D5(1'b0),
    .D6(1'b0),
    .D7(1'b0),
    .D8(1'b0),

    .OCE(1'b0), // 1-bit input: Output data clock enable
    .RST(serdes_rst), // 1-bit input: Reset

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


OBUFDS #(
    .IOSTANDARD("TMDS_33"),
    //.SLEW("FAST")
) tmds_diff_pair_out (
    .I(serial_out),
    .O(tmds_o_p),
    .OB(tmds_o_n),
);
endmodule
`default_nettype wire
