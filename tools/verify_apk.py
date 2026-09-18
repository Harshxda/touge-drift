#!/usr/bin/env python3
"""Structural verification only; signing and device tests remain separate."""
import hashlib
from pathlib import Path
import sys
import zipfile
apk = Path(sys.argv[1])
assert apk.stat().st_size > 0, 'Empty APK'
with zipfile.ZipFile(apk) as archive:
    assert archive.testzip() is None, 'Corrupt ZIP member'
    names = archive.namelist()
    for required in ['AndroidManifest.xml', 'classes.dex', 'assets/project.binary',
                     'assets/scripts/car.gdc', 'assets/scripts/drift_assist.gdc',
                     'assets/scripts/chase_camera.gdc', 'assets/scripts/hud.gdc',
                     'assets/scripts/track.gdc', 'assets/scripts/world.gdc',
                     'assets/scenes/world.tscn.remap', 'lib/arm64-v8a/libgodot_android.so']:
        assert required in names, f'Missing {required}'
    assert any(n.endswith('world.scn') for n in names), 'Missing compiled world scene'
    assert not any(n.startswith('assets/tests/') for n in names), 'Tests accidentally packaged'
    abis = sorted({n.split('/')[1] for n in names if n.startswith('lib/')})
    assert abis == ['arm64-v8a'], f'Unexpected ABIs: {abis}'
print(f'PASS: {apk.name}; {apk.stat().st_size} bytes; ZIP, resources, ARM64')
print(f'SHA256 {hashlib.sha256(apk.read_bytes()).hexdigest()}')
