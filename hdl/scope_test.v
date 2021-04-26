`default_nettype none
module scope_test #(
    parameter CLK_I_FREQ = 100_000_000,
    parameter CLK_I_MULT = 15, // Make sure not to exceed PLL_Fvcomax (1.6 GHz for -1 speed grade on Artix 7 parts)
    parameter CLK_I_DIV = 1,
    parameter CLK_SERIAL_DIV = 12,
    parameter CLK_LOGIC_DIV = 15
) (
    input wire clk_i,

    output wire tmds_red_p_o,
    output wire tmds_red_n_o,
    output wire tmds_green_p_o,
    output wire tmds_green_n_o,
    output wire tmds_blue_p_o,
    output wire tmds_blue_n_o,
    output wire tmds_clk_p_o,
    output wire tmds_clk_n_o,

    output wire led_logic_clk_o,
    output wire led_serial_clk_o,
    output wire led_parallel_clk_o
);

// Begin with a reset
reg [$clog2(100)-1:0] time_to_reset_done = 100;
always @(posedge clk_i)
    if (time_to_reset_done == 0)
        time_to_reset_done <= 0;
    else
        time_to_reset_done <= time_to_reset_done - 1;
wire reset = time_to_reset_done != 0;

/*
 * Create three clocks for the rest of the design.
 *
 * Notes:
 *  The frequency for any given CLKOUTx is equal to Fclkin1 * CLKFBOUT_MULT / DIVCLK_DIVIDE / CLKOUTx_DIVIDE
 *
 * Reset requirements:
 *  None. RST may be asserted and deasserted asynchronously.
 */
wire clk_pll_feedback, clk_logic, clk_parallel, clk_serial, pll_locked;
PLLE2_BASE #(
    .BANDWIDTH("OPTIMIZED"), // OPTIMIZED, HIGH, LOW
    .CLKFBOUT_MULT(CLK_I_MULT), // Multiply value for all CLKOUT, (2-64)
    .CLKFBOUT_PHASE(0.0), // Phase offset in degrees of CLKFB, (-360.000-360.000).
    .CLKIN1_PERIOD(1e9 / CLK_I_FREQ), // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).

    // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
    .CLKOUT0_DIVIDE(CLK_LOGIC_DIV),
    .CLKOUT1_DIVIDE(CLK_SERIAL_DIV),
    .CLKOUT2_DIVIDE(CLK_SERIAL_DIV*5), // the parallel (pixel) clock must be 1/5 the serial clock for OSERDESE2 in 10:1 DDR mode
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
    .CLKOUT0(clk_logic),
    .CLKOUT1(clk_serial),
    .CLKOUT2(clk_parallel),
    .CLKOUT3(),
    .CLKOUT4(),
    .CLKOUT5(),

    // Feedback Clocks: 1-bit (each) output: Clock feedback ports
    .CLKFBOUT(clk_pll_feedback), // 1-bit output: Feedback clock

    // Status Port: 1-bit (each) output: PLL status ports
    .LOCKED(pll_locked), // 1-bit output: LOCK

    // Clock Input: 1-bit (each) input: Clock input
    .CLKIN1(clk_i), // 1-bit input: Input clock

    // Control Ports: 1-bit (each) input: PLL control ports
    .PWRDWN(1'b0), // 1-bit input: Power-down
    .RST(reset), // 1-bit input: Reset

    // Feedback Clocks: 1-bit (each) input: Clock feedback ports
    .CLKFBIN(clk_pll_feedback) // 1-bit input: Feedback clock
);

/*
 * For each clock, flash an LED at a rate proportional to the clock frequency
 */
reg [24:0]
    counter_logic_clk    = 0,
    counter_parallel_clk = 0,
    counter_serial_clk   = 0;
always @(posedge clk_logic)
    counter_logic_clk <= counter_logic_clk + 1;
always @(posedge clk_parallel)
    counter_parallel_clk <= counter_parallel_clk + 1;
always @(posedge clk_serial)
    counter_serial_clk <= counter_serial_clk + 1;
assign led_logic_clk_o    = counter_logic_clk[24];
assign led_parallel_clk_o = counter_parallel_clk[24];
assign led_serial_clk_o   = counter_serial_clk[24];

/*
 * synchronize the pll_locked signal to the logic clock domain
 */
wire reset_logic_domain_n;
reset_synchronizer #(
    .COUNT(50)
) pll_locked_synchronizer (
    .clk_i(clk_logic),
    .reset_n_i(pll_locked),
    .reset_n_o(reset_logic_domain_n)
);
wire reset_logic_domain = ~reset_logic_domain_n;

/*
 * Generate a compliance pattern for testing on the scope
 */
wire fifo_full;
wire [9:0] pattern;
wire write_pattern = !fifo_full;
lfsr compliance_pattern_generator(
    .clk_i(clk_logic),
    .rst_i(reset_logic_domain),
    .next_i(write_pattern),
    .output_o(pattern)
);

/*
 * Serialize and buffer the pattern
 */
tmds #(
    .OBUFDS_IOSTANDARD("TMDS_33")
) hdmi_buf (
    .clk_logic_i(clk_logic),
    .clk_parallel_i(clk_parallel),
    .clk_serial_i(clk_serial),
    .clocks_stable_i(pll_locked),
    .symbol_fifo_full_o(fifo_full),
    .write_symbol_i(write_pattern),
    .symbol_i(pattern),
    .tmds_p_o(tmds_red_p_o),
    .tmds_n_o(tmds_red_n_o)
);

OBUFDS #(
    .IOSTANDARD("TMDS_33")
) tmds_green (
    .I(clk_parallel),
    .O(tmds_green_p_o),
    .OB(tmds_green_n_o)
);
OBUFDS #(
    .IOSTANDARD("TMDS_33")
) tmds_blue (
    .I(clk_parallel),
    .O(tmds_blue_p_o),
    .OB(tmds_blue_n_o)
);
OBUFDS #(
    .IOSTANDARD("TMDS_33")
) tmds_clk (
    .I(clk_parallel),
    .O(tmds_clk_p_o),
    .OB(tmds_clk_n_o)
);

endmodule
`default_nettype wire
