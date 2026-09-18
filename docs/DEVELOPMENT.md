# Development notes

## 2026-09-18 — initial vertical slice
Private remote was empty. Created a Godot 4.5.1 project, procedural assets and
matching Android build environment. Tools are installed outside the source tree
at `/home/kali/touge-tools`; templates are in the usual Godot user data folder.
OpenJDK 17 and Android SDK 35 are configured in local Godot Editor Settings.
No signing keys, toolchain archives or generated caches belong in Git.

Implemented custom velocity-based arcade handling, separated assistance,
automatic gear feedback, multitouch, chase camera with obstruction ray, drift
scoring/combo/recovery, checkpoint fall recovery, quality toggle, original car,
headlights, brake lights and bounded GPU smoke. Procedural 1.652 km route has six
24 m radius hairpins, forest, mountain silhouettes, road barriers, tunnel gallery,
small sakura cluster, launch apron, end apron and distant emissive city lights.
Repeated box geometry and trees use MultiMesh. No real-time shadows, expensive
screen-space reflections or volumetric fog. Internal scale defaults to 0.75.

Physics tests exposed insufficient drift angle and a countersteer correction
sign error; both fixed. A deterministic route-following test drives the entire
road using the actual controller/collisions, not teleportation. It contacts the
barrier for 13 physics frames; this is an automated navigability check, not proof
of enjoyable human driving or collision-free optimal lines.

Known prototype limitations:
- Car, terrain, trees, gallery and road are greybox procedural forms; visual
  direction needs an art pass. Start/end aprons are basic, not a social turnout.
- Six switchbacks establish scale; the authored signature left-sweeper/tunnel/
  hard-right/overlook composition still needs route design refinement.
- No engine/tire audio, skid decals, petals, mirrors or proper reflections yet.
- Automatic gear is speed-selected feedback over an arcade speed/torque curve,
  not a simulated gearbox. All assist parameters are code/Resource tunable;
  there is no tuning menu.
- Quality currently scales resolution and smoke only. Vegetation, shadows,
  reflection and post-processing presets should be added when those systems
  are profiled and warrant them.
- Camera uses one obstruction ray; tunnel wall/corner behavior requires human
  testing. Safe-area behavior and physical button ergonomics need tablet checks.
- Scores are session-only. No save/progression, pause menu, controller support,
  city, garage, rivals, traffic or police.
- No Android device is attached. No emulator or hardware performance claim.

Next gate: install on Pad 7, test simultaneous touch controls through repeated
hairpins, tune assist/camera from observed driving, record frame-time p50/p95/p99
and thermal behavior over 10+ minutes. Only then decide whether v0.1 is Playable.
Do not advance into city/progression while this gate remains open.
