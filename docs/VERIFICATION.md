# Verification — v0.2 Practice

Date: 2026-09-20. Godot 4.5.1 official. Android debug-signed ARM64 sideload build.
This is a prototype, not hardware acceptance certification.

## Automated host checks
- Godot script/resource import; acceleration, braking, handbrake initiation,
  sustained scoreable slide, recovery, banking and reverse.
- Simultaneous synthetic touch inputs and focus cleanup.
- Controller deadzone, proportional steering/triggers, simultaneous handbrake,
  independent release, reset, X/Square mode switch, disconnect and focus cleanup.
- Practice ground contact, 2.62 full doughnuts per direction over 20 seconds,
  1,193 drifting frames out of 1,200 per direction, zero barrier-contact frames.
- Practice does not advance/finish the downhill; reset, mode switching and
  physically driving through the exit work.
- Full 1,652.39 m descent through physics: 6,556 frames, 26 barrier-contact frames,
  peak slip 38.81°. This checks navigability, not clean human racing lines.
- All car body vertices remain referenced after merging with indexed box parts.
- Skid geometry capped at 768 segments; audio loop length uses samples,
  independent of compressed asset byte length.

## Presentation check
Host Mobile Vulkan renderer on llvmpipe software rendering. Inspected actual
parking/car/palette/HUD, drifting/skid and downhill captures. This is not a
hardware GPU performance result. Audio assets are original deterministic
synthesis (`tools/generate_audio.py`); physical-device listening is pending.

## Package checks
Use `BUILD_VERIFICATION-v0.2.txt` for final hash, size, signature, alignment and
manifest evidence. Expected package: `com.harshxda.tougedrift`, version code 2,
version `0.2.0-practice`, minimum SDK 24, target SDK 35, landscape, ARM64 only.
Archive checks require the coupe/feedback scripts and both imported audio
resources, and exclude tests. The previous APK remains available separately.

## Still unverified
ADB reports no attached device. Android installation/launch, real multitouch,
Xbox and DualSense mappings over Bluetooth/USB, disconnect/reconnect on hardware,
background/resume behavior, human drift feel and camera comfort, audio balance,
crash behavior and sustained Pad 7 60 FPS require device testing.

On Pad 7: try left/right doughnuts, throttle-controlled radius changes,
figure-eights, recovery, reset, mode switch, drive-through exit and a full run.
Test both controllers and touch; test background/resume and disconnect while
holding throttle. Profile both quality presets for at least 10 minutes and
inspect logcat. Do not call this hardware-verified or 60 FPS confirmed yet.

The Godot template's pre-existing unused themed-icon resource reference may
still produce an aapt2 warning. Signing and alignment verification are separate;
actual Android launcher appearance remains untested.
