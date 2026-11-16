#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

GHDL_BIN="${GHDL:-ghdl}"

"$GHDL_BIN" -a --std=08 hardware/rtl/countdown_core.vhd
"$GHDL_BIN" -a --std=08 hardware/rtl/countdown_controller.vhd
"$GHDL_BIN" -a --std=08 hardware/rtl/countdown_io.vhd
"$GHDL_BIN" -a --std=08 hardware/rtl/countdown_peripheral.vhd
"$GHDL_BIN" -a --std=08 hardware/sim/countdown_controller_tb.vhd
"$GHDL_BIN" -a --std=08 hardware/sim/countdown_tb.vhd

"$GHDL_BIN" -e --std=08 countdown_controller_tb
"$GHDL_BIN" -r --std=08 countdown_controller_tb --assert-level=error --stop-time=20us

"$GHDL_BIN" -e --std=08 countdown_tb
"$GHDL_BIN" -r --std=08 countdown_tb --assert-level=error --stop-time=20us
