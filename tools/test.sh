#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${GODOT:=godot}"
"$GODOT" --headless --editor --import
"$GODOT" --headless --fixed-fps 60 --path . --script res://tests/physics_test.gd
"$GODOT" --headless --fixed-fps 60 --path . --script res://tests/downhill_test.gd
