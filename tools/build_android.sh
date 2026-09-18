#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${GODOT:=godot}"
export GODOT
./tools/test.sh
mkdir -p builds
"$GODOT" --headless --path . --export-debug Android builds/touge-drift-v0.1-prototype.apk
python3 tools/verify_apk.py builds/touge-drift-v0.1-prototype.apk
