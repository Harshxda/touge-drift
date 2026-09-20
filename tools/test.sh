#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${GODOT:=godot}"
"$GODOT" --headless --editor --import --quit
"$GODOT" --headless --fixed-fps 60 --path . --script res://tests/physics_test.gd
"$GODOT" --headless --fixed-fps 60 --path . --script res://tests/downhill_test.gd
"$GODOT" --headless --path . --script res://tests/controller_test.gd
"$GODOT" --headless --fixed-fps 60 --path . --script res://tests/practice_test.gd
"$GODOT" --headless --path . --script res://tests/visual_test.gd
