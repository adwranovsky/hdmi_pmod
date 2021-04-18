`default_nettype none
module reset_synchronizer #(
    parameter COUNT = 20
) (
    input wire clk_i,
    input wire reset_n_i,
    output reg reset_n_o
);
    // Bring reset_n into this clock domain
    reg [1:0] reset_n_metastable;
    reg reset_n_stable;
    always @(posedge clk_i) begin
        reset_n_metastable[0] <= reset_n_i;
        reset_n_metastable[1] <= reset_n_metastable[0];
        reset_n_stable <= reset_n_metastable[1];
    end

    // Wait some number of clock cycles to deassert reset_n_o
    reg [$clog2(COUNT)-1:0] counter;
    always @(posedge clk_i) begin
        if (reset_n_stable == 0)
            counter <= COUNT;
        else if (counter == 0)
            counter <= 0;
        else
            counter <= counter - 1;
    end

    // Register reset_n_o
    always @(posedge clk_i)
        reset_n_o <= counter == 0;

endmodule
`default_nettype wire
