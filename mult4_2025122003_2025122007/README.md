# 4-bit Array Multiplier (RTL to GDSII)

## Team Members

- Roll Number: 2025122003
- Roll Number: 2025122007

All commands are run from this folder (`mult4_2025122003_2025122007/`) inside the
IIC-OSIC-TOOLS container, in the order listed.

## Environment check

```sh
iverilog -V | head -1
yosys -V
sta -version
echo $PDK_ROOT $PDK          # should show sky130A; if not: sak-pdk sky130A
```

## Part A — RTL simulation

```sh
iverilog -g2012 -o sim tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
vvp sim                      # PASS: 256 vectors checked, 0 errors
gtkwave mult.vcd
```

Error test (task 6): temporarily change `sum` in `rtl/full_adder.v` to `a ^ b`, rerun the
two commands above (prints `FAIL: 256 vectors checked, 95 errors`), then undo the change.

## Part B — Synthesis and gate-level simulation

```sh
yosys -c synth/synth.tcl

CELLS=$PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/verilog
iverilog -g2012 -DFUNCTIONAL -DUNIT_DELAY=#1 -o gls \
  tb/tb_mult.v $CELLS/primitives.v $CELLS/sky130_fd_sc_hd.v synth/mult_array_netlist.v
vvp gls
```




