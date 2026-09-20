# Verification — v0.1 prototype candidate

Date: 2026-09-18. Godot 4.5.1 stable official. This document records evidence,
not a Playable certification. APK is a debug-signed ARM64 sideload build.

## Automated host checks
- Script import and headless physics: pass.
- Ground contact, acceleration >72 km/h, braking: pass.
- Handbrake initiation, scoreable assisted angle, scoring, recovery, score
  banking, reverse: pass. Test slide around 15° under its scripted inputs.
- Independent synthetic steering/throttle touches, independent release and
  focus-loss cleanup: pass. This does not test a real Android touch driver.
- Full 1,652.39 m route driven through actual physics to finish: pass in 6,581
  physics frames; 13 barrier-contact frames; peak slip about 30.25°.
- Mobile Vulkan renderer launches on host llvmpipe software rendering: pass.
  Actual screenshot inspected for road, car, HUD, lamps and headlight pools.
  This is not an Android GPU result or a valid 60 FPS benchmark.

## APK checks
- File exists and is nonzero; ZIP CRC integrity: pass.
- Expected compiled world scene, all six gameplay scripts and project settings:
  packaged; test scripts excluded.
- Native libraries: arm64-v8a `libgodot_android.so` and `libc++_shared.so`.
- Package `com.harshxda.tougedrift`; version `0.1.0-prototype`; version code 1.
- Minimum SDK 24; target SDK 35; landscape activity and launcher intent.
- APK signature v2/v3: verified with Android apksigner, Android Debug certificate.
- See `BUILD_VERIFICATION.txt` for final hash, byte count and tool output.

The legacy `aapt dump badging` command reports a typed-attribute parsing error
on the Godot template. Manifest inspection uses `aapt2 dump xmltree` instead.
The non-Gradle Godot template retains an unused themed-icon resource-table
reference after replacing the active icon XML. aapt2 still warns about this
missing themed_icon.xml, despite the supplied original monochrome icon. APK
signature and alignment checks pass; actual launcher behavior remains untested.

## Not tested / release blockers
ADB lists no attached devices. No Android emulator was run; this host exposes
no /dev/kvm. APK installation, Android launch, hardware touch, real sustained
drift feel/transitions, usable camera throughout a human run, Android headlight
rendering, Android crash behavior and Pad 7 stable 60 FPS remain **untested**.

On the tablet, complete all ten game-plan acceptance steps. Test left+gas,
right+gas, brake+steer, gas+handbrake+steer, lifting one finger, dragging off a
button, app background/resume, both quality presets, a full downhill and retry.
Capture `adb logcat` for script/Vulkan/crash errors. Profile at least 10 minutes
with smoke and tunnel lighting, including the last five minutes after warm-up.
Record actual render scale, refresh rate and frame-time distribution.

**Do not label this build “Touge Drift v0.1 — Playable” until those tests pass.**
