#!/bin/sh
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT HUP INT TERM
cd "$build_dir"
"${GHDL:-ghdl}" -a --std=08 "$repo_dir/hardware/rtl/countdown_controller.vhd" "$repo_dir/hardware/sim/countdown_controller_tb.vhd"
"${GHDL:-ghdl}" -e --std=08 countdown_controller_tb
"${GHDL:-ghdl}" -r --std=08 countdown_controller_tb --assert-level=error --stop-time=20us
"${GHDL:-ghdl}" --synth --std=08 countdown_controller > /dev/null
