#include <stdio.h>
#include <ncurses.h>
#include <chrono>
#include <vector>

#include "verilated.h"

#include "ModelUtils.h"

// DUT
#include "Vlfsr.h"


int main(int argc, const char *argv[]) {
    /*
     * Initialize Verilator
     */
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(false);

    // Instantiate our design testbench
    Testbench<Vlfsr> tb(NULL, 0); // No trace file and no tick limit
    // Initialize inputs
    auto *top = tb.get_dut();
    top->clk_i = 0;
    top->rst_i = 1;
    top->next_i = 1;

    /*
     * Stay in reset for a few cycles
     */
    for (int i = 0; i < 5; i++)
        tb.tick();
    top->rst_i = 0;

    /*
     * Simulate for 1024 cycles
     */
    for (int i = 0; i < 1024; i++) {
        tb.tick();
        printf("%d\n", top->output_o);
    }

    return 0;
}
