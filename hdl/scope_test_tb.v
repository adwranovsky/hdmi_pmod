`default_nettype none
module scope_test_tb();

wire tmds_p_o, tmds_n_o;
reg clk_100_Mhz = 0;
initial forever begin
    #5 clk_100_Mhz = ~clk_100_Mhz;
end

scope_test dut (
    .clk_i(clk_100_Mhz),
    .tmds_p_o(tmds_p_o),
    .tmds_n_o(tmds_n_o)
);

integer i;
initial begin
    $dumpfile("scope_test_tb.vcd");
    $dumpvars(3, scope_test_tb);
    for (i=0; i<10; i=i+1)
        @(posedge tmds_p_o);
    $finish;
end

endmodule
`default_nettype wire
