# HDMI PMOD HDL
Included is some example code and a [FuseSoC](https://github.com/olofk/fusesoc) core file to get up and running with the PMOD. See the FuseSoC documentation on how to run the different targets. Some of the simulation targets depend on [my cores library](https://github.com/adwranovsky/CoreOrchard) which can be installed via FuseSoC.

# Targets
The corefile has the following targets.

## sim_lfsr
A Verilator simulation that prints out the whole LFSR sequence from `lfsr.v`.

## scope_test
Creates a bitstream for a project that puts out a test pattern on pair 1 of JB on the Arty A7 using a 3.3V TMDS driver. The other pairs output the pixel clock. Synthesis is done with Yosys and place and route is done with Vivado.

## sim_scope_test
A simple simulation of scope_test that ends after 10 positive edges of pair 1. Simulation is done with xsim.

# Gotchas
## xsim failed to compile generated C file xsim_1.c
Xsim seems to require the ncurses 5 library, so use your package manager to install it. On Gentoo you can do this with
```
emerge --ask sys-libs/ncurses-compat
```
