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
echo $PDK_ROOT $PDK        
```
## Docker CLI

```sh
docker run -it --rm -v "$PWD":/foss/designs/mult hpretl/iic-osic-tools:latest -s /bin/bash
```

## Docker GUI

Requires Docker (on Windows: Docker Desktop with WSL integration, and run the shell
commands below in a WSL Ubuntu terminal). Check that WSL responds (PowerShell):

```powershell
wsl -l -v
```

Clone this repo and the IIC-OSIC-TOOLS launch scripts side by side:

```sh
git clone https://github.com/DevangBordoloi/RTL-to-GDS-4-bit-array-multiplier-.git
git clone --depth 1 https://github.com/iic-jku/IIC-OSIC-TOOLS.git
```

Start the GUI container with this repo mounted at `/foss/designs` (`start_vnc.sh` creates
the container on first run and restarts it if it is stopped):

```sh
DESIGNS="$PWD/RTL-to-GDS-4-bit-array-multiplier-" ./IIC-OSIC-TOOLS/start_vnc.sh
```

Check that the GUI is up (should print `200`):

```sh
docker ps --format '{{.Names}} | {{.Ports}} | {{.Status}}'
docker logs --tail 15 iic-osic-tools_xvnc_uid_$(id -u)
curl -s -o /dev/null -w '%{http_code}\n' http://localhost/
```

Open http://localhost/?password=abc123 in a browser, then in the desktop's terminal:

```sh
cd /foss/designs/mult4_2025122003_2025122007
```

Stop the container (start it again with `docker start iic-osic-tools_xvnc_uid_$(id -u)`):

```sh
docker stop iic-osic-tools_xvnc_uid_$(id -u)
```

If an older `iic-osic-tools_xvnc_uid_*` container already exists with a different design
folder mounted, remove it with `docker rm -f iic-osic-tools_xvnc_uid_$(id -u)` and run
`start_vnc.sh` again.

## Part A — RTL simulation

```sh
iverilog -g2012 -o sim tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
vvp sim                     
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

## Part C — Synthesis and gate-level simulation
```sh
sta sta/sta.tcl                    
CLK_PERIOD=2.51 sta sta/sta.tcl    
```

## Part D — RTL to GDSII
```sh
librelane config.json 
grep -E '"(design__core__area|design__instance__count|design__instance__count__stdcell|design__instance__count__class:[a-z_]+|route__wirelength|timing__setup__ws|timing__hold__ws|route__drc_errors|magic__drc_error__count|klayout__drc_error__count|design__lvs_error__count)":' metrics.json
```



