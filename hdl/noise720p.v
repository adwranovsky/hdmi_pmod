`default_nettype none
module noise720p #(
    parameter CLK_I_FREQ = 100_000_000,
    parameter CLK_I_MULT = 15, // Make sure not to exceed PLL_Fvcomax (1.6 GHz for -1 speed grade on Artix 7 parts)
    parameter CLK_I_DIV = 1,
    parameter CLK_SERIAL_DIV = 4,
    parameter CLK_LOGIC_DIV = 15
) (
    input wire clk_i,

    input wire reset_i,
    output wire reset_led_o,

    output wire led_logic_clk_o,
    output wire led_serial_clk_o,
    output wire led_parallel_clk_o,

    output wire tmds_red_p_o,
    output wire tmds_red_n_o,
    output wire tmds_green_p_o,
    output wire tmds_green_n_o,
    output wire tmds_blue_p_o,
    output wire tmds_blue_n_o,
    output wire tmds_clk_p_o,
    output wire tmds_clk_n_o
);

// synchronize reset_i to the input oscillator domain
reg reset_i_sync, reset_i_metastable;
always @(posedge clk_i)
    {reset_i_sync, reset_i_metastable} <= {reset_i_metastable, reset_i};

// Begin with a reset. This signal is only valid in the input oscillator (clk_i) domain.
localparam RESET_TIME = 100;
reg [$clog2(100)-1:0] time_to_reset_done = RESET_TIME;
always @(posedge clk_i)
    if (reset_i_sync)
        time_to_reset_done <= RESET_TIME;
    else if (time_to_reset_done == 0)
        time_to_reset_done <= 0;
    else
        time_to_reset_done <= time_to_reset_done - 1;
wire reset_input_oscillator_domain = time_to_reset_done != 0;
assign reset_led_o = reset_input_oscillator_domain;

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
    .RST(reset_input_oscillator_domain), // 1-bit input: Reset

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
 * synchronize the pll_locked signal to the logic clock domain and the parallel (pixel) clock domain
 */
wire reset_logic_domain_n;
reset_synchronizer #(
    .COUNT(50)
) logic_reset_synchronizer (
    .clk_i(clk_logic),
    .reset_n_i(pll_locked),
    .reset_n_o(reset_logic_domain_n)
);
wire reset_logic_domain = ~reset_logic_domain_n;

wire reset_parallel_domain_n;
reset_synchronizer #(
    .COUNT(50)
) parallel_reset_synchronizer (
    .clk_i(clk_parallel),
    .reset_n_i(pll_locked),
    .reset_n_o(reset_parallel_domain_n)
);
wire reset_parallel_domain = ~reset_parallel_domain_n;

/*
 * Generate the horizontal and vertical sync timings
 */
localparam COORD_WIDTH = 16;
wire [COORD_WIDTH-1:0] x_coordinate, y_coordinate;
wire hsync, vsync, data_enable, frame, line;
display_timings_720p #(
    .CORDW(COORD_WIDTH)
) display_timings (
    .clk_pix(clk_parallel),   // pixel clock
    .rst(reset_parallel_domain), // reset
    .hsync(hsync),    // horizontal sync
    .vsync(vsync),    // vertical sync
    .de(data_enable),       // data enable (low in blanking intervals)
    .frame(frame),    // high at start of frame
    .line(line),     // high at start of active line
    .sx(x_coordinate),       // horizontal screen position
    .sy(y_coordinate)        // vertical screen position
);

/*
 * Generate the video stream, which in this case is just a random stream of data from 3 LFSRs
 */
localparam COLOR_WIDTH = 8;
wire [COLOR_WIDTH-1:0] red, green, blue;
lfsr #(
    .WIDTH(10),
    .SEED(10'h3f7)
) red_stream (
    .clk_i(clk_parallel),
    .rst_i(reset_parallel_domain),
    .next_i(1'b1),
    .output_o(red)
);
lfsr #(
    .WIDTH(10),
    .SEED(10'h010)
) green_stream (
    .clk_i(clk_parallel),
    .rst_i(reset_parallel_domain),
    .next_i(1'b1),
    .output_o(green)
);
lfsr #(
    .WIDTH(10),
    .SEED(10'h1ae)
) blue_stream (
    .clk_i(clk_parallel),
    .rst_i(reset_parallel_domain),
    .next_i(1'b1),
    .output_o(blue)
);

/*
 * Encode the pixel data using the method described in the DVI spec
 */
wire [9:0] symbol_red, symbol_green, symbol_blue;
tmds_encoder_dvi encode_red (
    .clk_pix(clk_parallel),
    .rst(reset_parallel_domain),
    .data_in(red),
    .ctrl_in(2'b0), // spec requires red control signals be held low
    .de(data_enable),
    .tmds(symbol_red)
);
tmds_encoder_dvi encode_green (
    .clk_pix(clk_parallel),
    .rst(reset_parallel_domain),
    .data_in(green),
    .ctrl_in(2'b0), // spec requires green control signals be held low
    .de(data_enable),
    .tmds(symbol_green)
);
tmds_encoder_dvi encode_blue (
    .clk_pix(clk_parallel),
    .rst(reset_parallel_domain),
    .data_in(blue),
    .ctrl_in({vsync,hsync}), // spec requires blue control signals be tied to hsync+vsync
    .de(data_enable),
    .tmds(symbol_blue)
);

/*
 * Serialize and buffer the DVI signals
 */
dvi_buffer_xc7 #(
    .OBUFDS_IOSTANDARD("TMDS_33")
) dvi_buffer (
    .clk_parallel_i(clk_parallel),
    .clk_serial_i(clk_serial),
    .clocks_stable_i(pll_locked),

    .symbol_red_i(symbol_red),
    .symbol_green_i(symbol_green),
    .symbol_blue_i(symbol_blue),

    .tmds_red_p_o(tmds_red_p_o),
    .tmds_red_n_o(tmds_red_n_o),
    .tmds_green_p_o(tmds_green_p_o),
    .tmds_green_n_o(tmds_green_n_o),
    .tmds_blue_p_o(tmds_blue_p_o),
    .tmds_blue_n_o(tmds_blue_n_o),
    .tmds_clk_p_o(tmds_clk_p_o),
    .tmds_clk_n_o(tmds_clk_n_o)
);

endmodule
`default_nettype wire
