# HDL for the HDMI PMOD
## Requirements
The following hardware is required to run the examples:
* [Arty A7 35t](https://store.digilentinc.com/arty-a7-artix-7-fpga-development-board/) FPGA development board
* A 480p 60 Hz or 720p 60 Hz capable monitor, and matching cable
* An assembled HDMI PMOD, plugged into the JB port on the Arty A7 35t.

As for software, install the following first:
* [Vivado](https://developer.xilinx.com/en/products/vivado.html) (I use 2019.2 with the free WebPACK license)
* [FuseSoC](https://fusesoc.readthedocs.io/en/stable/user/installation.html)

After that, you will need to install my FuseSoC cores library.
```bash
fusesoc library add --global CoreOrchard https://github.com/adwranovsky/CoreOrchard.git
```

# Running the examples
All examples can be run using FuseSoC. For example, to build the noise720p design and load the bitstream onto your
board:
```bash
fusesoc --cores-root . run --target=noise720p 'adwranovsky:hardware:hdmi_pmod'
```

Feel free to dig around in `hdmi_pmod.core` to see what other targets are available!

# Gotchas
## xsim failed to compile generated C file xsim_1.c
XSIM seems to require the ncurses 5 library, so use your package manager to install it. On Gentoo you can do this with
```
emerge --ask sys-libs/ncurses-compat
```
