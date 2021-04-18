`default_nettype none

/*
 * TODO: pixel clock buf and output delays
 */

module tmds #(
    parameter OBUFDS_IOSTANDARD = "TMDS_33",
    parameter CLK_I_FREQ = 100000000,
    parameter CLK_I_MULT = 15, // Make sure not to exceed PLL_Fvcomax (1.6 GHz for -1 speed grade on Artix 7 parts)
    parameter CLK_I_DIV = 1,
    parameter VCO_DIV = 12
) (
    input wire clk_i,
    input wire rst_i,

    output wire symbol_fifo_full_o,
    input  wire write_symbol_i,
    input  wire [9:0] symbol_i,

    output wire tmds_p_o,
    output wire tmds_n_o
);


/*
 * Reset logic
 *  PLL reqs:
 *      None. RST may be asserted and deasserted asynchronously.
 *  OSERDES reqs:
 *      RESET may be asserted asynchronously, and must be deasserted synchronously with CLKDIV. RESET should only be
 *      deasserted once both clocks are stable.
 *  OUT_FIFO reqs:
 *      RESET must be asserted high for at least four clock cycles of the slowest clock. RDEN and WREN must be held low
 *      while RESET is asserted. RESET can be asserted and deasserted asynchronously. RESET should be asserted until all
 *      clocks are stable.
 *
 *  Synchronizing pll_locked to CLKDIV (parallel_clock), and then holding it low for at least 4 cycles of clk_i should
 *  create a reset signal that satisfies both the OSERDES module and the OUT_FIFO module. To handle WREN of the
 *  OUT_FIFO, we will also synchonize this signal to the clk_i clock domain, and use it to mask WREN.
 *
 */      
wire vco_div_clk, pll_locked;
wire serial_clock, parallel_clock; // parallel_clock must be x5 serial clock for 10 bit DDR mode
wire pll_locked, pll_locked_sync;
reset_synchronizer #(
    .COUNT(50) // This MUST be long enough to be at least 4 clock cycles of the slowest clock (probably parallel_clock)
) pll_locked_synchronizer (
    .clk_i(parallel_clock),
    .reset_n_i(pll_locked),
    .reset_n_o(pll_locked_sync)
);
wire reset_out_fifo_and_oserdes = ~pll_locked_sync;
wire rden_mask = pll_locked_sync;
// synchronize this signal to the clk_i domain as well so that we can use it to mask WREN
wire wren_mask_metastable, wren_mask;
always @(posedge clk_i)
    {wren_mask, wren_mask_metastable} <= {wren_mask_metastable, pll_locked_sync};

/*
 * Notes:
 *  The frequency for any given CLKOUTx is equal to Fclkin1 * CLKFBOUT_MULT / DIVCLK_DIVIDE / CLKOUTx_DIVIDE
 *
 * Reset requirements:
 *  None. RST may be asserted and deasserted asynchronously.
 */
PLLE2_BASE #(
    .BANDWIDTH("OPTIMIZED"), // OPTIMIZED, HIGH, LOW
    .CLKFBOUT_MULT(CLK_I_MULT), // Multiply value for all CLKOUT, (2-64)
    .CLKFBOUT_PHASE(0.0), // Phase offset in degrees of CLKFB, (-360.000-360.000).
    .CLKIN1_PERIOD(1e6 / CLK_I_FREQ), // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).

    // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
    .CLKOUT0_DIVIDE(VCO_DIV),
    .CLKOUT1_DIVIDE(VCO_DIV*5),  // the parallel (pixel) clock must be 1/5 the serial clock for OSERDESE2 in 10:1 DDR mode
    .CLKOUT2_DIVIDE(1),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT5_DIVIDE(1),

    // CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT5_DUTY_CYCLE(0.5),

    // CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
    .CLKOUT0_PHASE(0.0),
    .CLKOUT1_PHASE(0.0),
    .CLKOUT2_PHASE(0.0),
    .CLKOUT3_PHASE(0.0),
    .CLKOUT4_PHASE(0.0),
    .CLKOUT5_PHASE(0.0),

    .DIVCLK_DIVIDE(CLK_I_DIV), // Master division value, (1-56)
    .REF_JITTER1(0.0), // Reference input jitter in UI, (0.000-0.999).
    .STARTUP_WAIT("FALSE") // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
) pll (
    // Clock Outputs: 1-bit (each) output: User configurable clock outputs
    .CLKOUT0(serial_clock),
    .CLKOUT1(parallel_clock),
    .CLKOUT2(),
    .CLKOUT3(),
    .CLKOUT4(),
    .CLKOUT5(),

    // Feedback Clocks: 1-bit (each) output: Clock feedback ports
    .CLKFBOUT(vco_div_clk), // 1-bit output: Feedback clock

    // Status Port: 1-bit (each) output: PLL status ports
    .LOCKED(pll_locked), // 1-bit output: LOCK

    // Clock Input: 1-bit (each) input: Clock input
    .CLKIN1(clk_i), // 1-bit input: Input clock

    // Control Ports: 1-bit (each) input: PLL control ports
    .PWRDWN(1'b0), // 1-bit input: Power-down
    .RST(rst_i), // 1-bit input: Reset

    // Feedback Clocks: 1-bit (each) input: Clock feedback ports
    .CLKFBIN(vco_div_clk) // 1-bit input: Feedback clock
);


// Read from the FIFO whenever there is data ready, but keep RDEN low when in reset
wire fifo_empty;
wire fifo_rden = ~fifo_empty;
wire fifo_rden_masked = rden_mask & fifo_rden;
// Write to the FIFO when requested, except when in reset
wire fifo_wren_masked = wren_mask & write_symbol_i;

/*
 * An OUT_FIFO to transition between the logic clock domain (clk_i) and the pixel clock domain (parallel_clock). The
 * OUT_FIFO module is located adjacent to any OSERDES elements and the IO buffers.
 */
wire [9:0] serdes_parallel_in;
OUT_FIFO #(
    .ALMOST_EMPTY_VALUE(1), // Almost empty offset (1-2)
    .ALMOST_FULL_VALUE(1), // Almost full offset (1-2)
    .ARRAY_MODE("ARRAY_MODE_4_X_4"), // ARRAY_MODE_8_X_4, ARRAY_MODE_4_X_4
    .OUTPUT_DISABLE("FALSE"), // Disable output (FALSE, TRUE)
    .SYNCHRONOUS_MODE("FALSE") // Must always be set to false.
) out_fifo (
    // FIFO Status Flags: 1-bit (each) output: Flags and other FIFO status outputs
    .ALMOSTEMPTY(), // 1-bit output: Almost empty flag
    .ALMOSTFULL(), // 1-bit output: Alomst full flag
    .EMPTY(fifo_empty), // 1-bit output: Empty flag
    .FULL(symbol_fifo_full_o), // 1-bit output: Full flag

    // Q0-Q9: 4-bit (each) output: FIFO Outputs
    .Q0(serdes_parallel_in[3:0]), // 4-bit output: Channel 0 output bus
    .Q1(serdes_parallel_in[7:4]), // 4-bit output: Channel 1 output bus
    .Q2(serdes_parallel_in[9:8]), // 4-bit output: Channel 2 output bus
    .Q3(), // 4-bit output: Channel 3 output bus
    .Q4(), // 4-bit output: Channel 4 output bus
    .Q5(), // 8-bit output: Channel 5 output bus
    .Q6(), // 8-bit output: Channel 6 output bus
    .Q7(), // 4-bit output: Channel 7 output bus
    .Q8(), // 4-bit output: Channel 8 output bus
    .Q9(), // 4-bit output: Channel 9 output bus

    // D0-D9: 8-bit (each) input: FIFO inputs
    .D0(symbol_i[3:0]), // 8-bit input: Channel 0 input bus
    .D1(symbol_i[7:4]), // 8-bit input: Channel 1 input bus
    .D2(symbol_i[9:8]), // 8-bit input: Channel 2 input bus
    .D3(8'b0), // 8-bit input: Channel 3 input bus
    .D4(8'b0), // 8-bit input: Channel 4 input bus
    .D5(8'b0), // 8-bit input: Channel 5 input bus
    .D6(8'b0), // 8-bit input: Channel 6 input bus
    .D7(8'b0), // 8-bit input: Channel 7 input bus
    .D8(8'b0), // 8-bit input: Channel 8 input bus
    .D9(8'b0), // 8-bit input: Channel 9 input bus

    // FIFO Control Signals: 1-bit (each) input: Clocks, Resets and Enables
    .RDCLK(parallel_clock), // 1-bit input: Read clock
    .RDEN(fifo_rden_masked), // 1-bit input: Read enable
    .RESET(reset_out_fifo_and_oserdes), // 1-bit input: Active high reset
    .WRCLK(clk_i), // 1-bit input: Write clock
    .WREN(fifo_wren_masked) // 1-bit input: Write enable
);

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

    .CLK(serial_clock), // 1-bit input: High speed clock
    .CLKDIV(parallel_clock), // 1-bit input: Divided clock

    // D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
    .D1(serdes_parallel_in[0]),
    .D2(serdes_parallel_in[1]),
    .D3(serdes_parallel_in[2]),
    .D4(serdes_parallel_in[3]),
    .D5(serdes_parallel_in[4]),
    .D6(serdes_parallel_in[5]),
    .D7(serdes_parallel_in[6]),
    .D8(serdes_parallel_in[7]),

    .OCE(1'b1), // 1-bit input: Output data clock enable
    .RST(reset_out_fifo_and_oserdes), // 1-bit input: Reset

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
    .D3(serdes_parallel_in[8]),
    .D4(serdes_parallel_in[9]),
    .D5(1'b0),
    .D6(1'b0),
    .D7(1'b0),
    .D8(1'b0),

    .OCE(1'b0), // 1-bit input: Output data clock enable
    .RST(reset_out_fifo_and_oserdes), // 1-bit input: Reset

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
    .IOSTANDARD(OBUFDS_IOSTANDARD),
    //.SLEW("FAST")
) tmds_diff_pair_out (
    .I(serdes_serial_out),
    .O(tmds_p_o),
    .OB(tmds_n_o),
);
endmodule

`default_nettype wire
