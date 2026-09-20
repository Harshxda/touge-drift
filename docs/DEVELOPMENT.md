# Development notes

## 2026-09-20 — v0.2 Practice build
Implemented the 112 × 128 m practice pad, left/right doughnut reference circles,
parking bays, perimeter barriers and a drive-through downhill exit. Practice
is the default launch/reset location; mode switching works by touch, P, or
X/Square. Added lower-speed drift initiation and power slides, synthesized
engine/tire audio, bounded skid marks, higher camera framing and the yellow /
lavender / mint palette pass. Integrated the pending detailed coupe/scenery.
Visual inspection exposed indexed/unindexed mesh merging dropping car panels;
fixed it and added a regression test. Corrected the car collision height so
the wheels meet the road. APK version is 0.2.0-practice, version code 2.

Host tests sustain 2.62 doughnuts per direction over 20 seconds with zero
barrier contacts. The full descent passes with 26 barrier-contact frames.
These are automated checks, not proof of enjoyable human control. Physical
Android, Xbox/DualSense, Bluetooth/USB, audio balance and Pad 7 60 FPS remain
unverified. See VERIFICATION.md for release evidence and remaining checks.


## 2026-09-19 — controller support
Added Xbox / DualSense standard gamepad bindings, analog stick steering and
triggers, handbrake, reset, HUD hints, disconnect and focus-loss cleanup.
Synthetic input tests cover these paths; physical controllers, Android mappings
and Bluetooth/USB behavior remain unverified. Existing APK has not been rebuilt.

## 2026-09-19 — feedback recorded
User requested a parking space in the next version to do doughnuts and evaluate
drift initiation, control and feel. Added a dedicated summit practice-area
requirement and handling acceptance checks to GAME_PLAN.md. Not yet implemented.

Further clarification: art of rally is the overall base reference for every
relevant aspect of visuals, game feel, performance and sound, with Diamond Is
Unbreakable's visual color aesthetic layered on top. Expanded GAME_PLAN.md
accordingly; this records direction, not completed implementation.

User reiterated that the car is too grippy, wants art of rally as the visual
foundation, and clarified that the JJBA color reference is specifically
Diamond Is Unbreakable (Part 4). Recorded these requirements in GAME_PLAN.md.
Pending grip and visual changes are not yet evidence that this feedback is
fully addressed; handling validation and a deliberate reference-led art pass
remain outstanding.

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
- Scores are session-only. No save/progression, pause menu,
  city, garage, rivals, traffic or police.
- No Android device is attached. No emulator or hardware performance claim.

Next gate: install on Pad 7, test simultaneous touch controls through repeated
hairpins, tune assist/camera from observed driving, record frame-time p50/p95/p99
and thermal behavior over 10+ minutes. Only then decide whether v0.1 is Playable.
Do not advance into city/progression while this gate remains open.
