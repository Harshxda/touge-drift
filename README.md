# Touge Drift — v0.2 Practice

Android-first assisted drifting in Godot **4.5.1**, Mobile renderer.
Landscape, ARM64, Android 7+ (API 24), target API 35.

**Prototype build. Physical Android/controller playability and Pad 7 60 FPS
remain unverified.**

![Practice area, captured using the host Mobile renderer](docs/preview.png)

## What changed
- A flat **112 × 128 m practice parking area**, painted doughnut circles,
  parking bays, perimeter barriers, quick reset and an exit to the downhill.
- Lower rear grip, throttle-dependent slide grip and easier initiation,
  including power slides with strong steering and throttle.
- Xbox / DualSense analog steering and triggers, handbrake, reset and mode switch.
- A more detailed original coupe, repaired body-panel mesh merging and wheel
  height, a higher chase camera, and a yellow/lavender/mint color pass inspired
  by Diamond Is Unbreakable over the art of rally visual direction.
- Original synthesized engine/tire feedback and a fixed-budget skid trail.
  Audio is an initial procedural pass, not a finished soundtrack.

The original 1.65 km descent, six hairpins, tunnel, checkpoints, drift scoring
and quality presets remain available. Visual/game-feel references describe the
intended direction; this prototype is not yet equivalent to those references.

## Play
Open `project.godot` in Godot 4.5.1 and press F5, or install
`builds/touge-drift-v0.2-practice.apk` on a compatible Android device.
The game starts in the parking area. Drive through the marked exit or select
**GO DOWNHILL**. **PRACTICE LOT** returns to the parking area; **RESET** restarts
in the current mode.

| Action | Touch | Keyboard | Xbox | DualSense |
| --- | --- | --- | --- | --- |
| Steering | Left/right | A/D or arrows | Left stick | Left stick |
| Gas | GAS | W / Up | RT | R2 |
| Brake/reverse | BRAKE | S / Down | LT | L2 |
| Handbrake | HANDBRAKE | Space | A | Cross |
| Reset | RESET | R | Y | Triangle |
| Practice/downhill | Mode button | P | X | Square |

Controller steering has a rescaled 15% deadzone. Pair/connect the controller
through the operating system. Actual Bluetooth/USB mappings on Pad 7 still
need testing. Touch remains available while a controller is connected.

For a doughnut, build some speed, steer and briefly hold the handbrake, then
release it and balance throttle/steering. Partial trigger pressure gives finer
control. Strong steering and throttle can also break traction above 20 km/h.
Scoreable drifts need >25 km/h and a 12–70° slip angle. Practice has no finish
trigger or time limit. Quality switches between 75%/48 smoke particles and
60%/24 particles; skid geometry is capped at 768 segments.

## Build and verify
Set `GODOT` to Godot 4.5.1 and run `tools/test.sh` for import, physics, complete
route, controller, practice and car-mesh regression checks. Run
`tools/build_android.sh` to test, export and check the APK archive/resources.
Configure Java 17, matching export templates, SDK platform 35 and build-tools
35.0.0 in Godot Editor Settings first. Keep the debug keystore outside Git.

Also verify the APK with `apksigner verify --verbose`, `zipalign -c -P 16 4`,
and `aapt2 dump xmltree <apk> --file AndroidManifest.xml`.

Install: `adb install -r builds/touge-drift-v0.2-practice.apk`

Launch: `adb shell am start -n com.harshxda.tougedrift/com.godot.game.GodotApp`

See [verification](docs/VERIFICATION.md), [development notes](docs/DEVELOPMENT.md)
and [project direction](docs/GAME_PLAN.md). Builds/cache are ignored by Git.
No city, economy, traffic, police or rivals are implemented.
