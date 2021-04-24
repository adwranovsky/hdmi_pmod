# HDL for the HDMI PMOD
# Gotchas
## xsim failed to compile generated C file xsim_1.c
XSIM seems to require the ncurses 5 library, so use your package manager to install it. On Gentoo you can do this with
```
emerge --ask sys-libs/ncurses-compat
```
