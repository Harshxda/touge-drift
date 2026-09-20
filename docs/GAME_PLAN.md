# TOUGE DRIFT — approved project direction

Android-first arcade drifting in Godot 4 / GDScript, Mobile renderer, landscape.
Baseline hardware: Xiaomi Pad 7. Target stable 60 FPS; measurement required.
North star: a beautiful car, a beautiful road, great lighting, smooth performance,
and a drift system that invites one more hairpin.

## User feedback — clarified 2026-09-19
- Handling: the current car feels too grippy. Make drifting easier to initiate
  and sustain; validate the feel rather than treating parameter changes as done.
- Overall foundation: use art of rally as the primary reference across all
  relevant aspects: visuals, game feel, performance and sound. This is broader
  than a composition reference. Build original assets and implementation toward
  that cohesive experience, adapted to this Android touge drifting game.
- Visual scope includes car and scenery forms, composition, lighting, camera
  readability, effects and UI restraint. Driving scope includes responsive
  control, readable weight transfer, controllable slides and satisfying recovery;
  the explicit request for less grip remains an acceptance requirement.
- Sound direction should support that same experience through engine, tire,
  surface and ambient feedback, using original or appropriately licensed audio.
  Performance acceptance remains measured, stable 60 FPS on Xiaomi Pad 7;
  resemblance to a reference is not evidence of equivalent performance.
- Color direction: specifically JoJo's Bizarre Adventure: Diamond Is Unbreakable
  (Part 4), not a generic JJBA palette. Layer its visual color aesthetic on top
  of the art of rally foundation. This supersedes conflicting earlier
  palette guidance; exact colors still need a visual pass and review.

## Vision and originality
Minimalist elegance, original Japanese street-racing atmosphere, accessible
assisted drifting, and a memorable mountain. Art of rally is the primary
experience reference for visuals, handling feel, sound and performance, with
Diamond Is Unbreakable providing the overlaid color aesthetic. Japanese touge
culture and early/mid-2000s street-racing atmosphere inform the setting.
Use original maps, branding, car models, code and original or licensed audio.
Driving takes priority over menus and simulation complexity.

## Driving, assistance, controls, camera
Player controls line, steering, throttle, brake/reverse, drift initiation and
handbrake. Assist manages countersteer, stability, angle recovery, excessive
rotation and transition back to grip. Typical corner: approach, brake/handbrake,
rear rotation, steering plus throttle, assist catch, line control, straighten.
Tune drift_assist, countersteer_strength, rear_grip, steering_speed, stability
separately from base vehicle physics. Use a custom controller, not default
VehicleBody3D handling. Focus on Assisted first; Assisted+, Sport, Manual later.
Automatic transmission for the first fictional S13/S15-inspired RWD coupe.

Tablet landscape controls: generous left/right steering at left; throttle,
brake/reverse and handbrake at right. Independent fingers must work together;
controls must not obscure the next corner. Analog touch region later. Xbox and DualSense controller support is required:
left stick steering, analog triggers for gas/brake, A/Cross handbrake and
Y/Triangle reset. Verify both controllers on Pad 7, including disconnect/reconnect.
Cinematic chase camera: elevated but close enough for a substantial car,
readable road and drift angle, speed-responsive composition, smooth transitions.
Camera is a highest-priority system, alongside handling.

## Presentation and content
Use original fictional Japanese performance-car archetypes. Start with one RWD
coupe; later lightweight AE86-like coupe, rotary-sports-car archetype, AWD coupe,
GT, modern RWD, AWD sedans. Visible wheels/fitment, lamps, brake lights,
reflections, exhaust and body details; customization later. Cars have more
visual detail than surroundings. Quality comes from composition, silhouette,
lighting, reflections, motion, smoke, road design and color rather than realism.

Mountain with Diamond Is Unbreakable-inspired color direction: winding asphalt, forest, retaining
walls, reflective guardrails, utility poles, signs, tunnels, warm lights,
sweeping headlights, stylized tire smoke, distant city. Restrained sakura only
at overlook, turnout, shrine-like location or a special section; occasional
petals later. Signature future sequence: hairpin, short straight, left sweeper,
tunnel, hard right hairpin, overlook.

Mountain gathering turnout eventually contains 4–6 tuned cars, vending machines,
parking barriers, streetlights, views. Driving up to another driver starts a
challenge/downhill chase rather than forcing menu-based discovery.

## Milestones and scope
v0.2 Practice — implemented; physical-device acceptance pending:
- Add a broad, flat parking area connected to the summit start, available
  immediately for testing before committing to the downhill.
- Leave enough unobstructed space for continuous doughnuts in either direction,
  figure-eights, and repeated drift initiation and recovery. Keep scenery and
  solid obstacles at the perimeter, with generous runoff.
- Use painted circles, parking bays and optional future cone markers to judge
  radius and line control without cluttering the driving space.
- Provide a quick reset to the practice start and readable speed/drift-angle
  feedback. Practice should not trigger the downhill finish or require a timer.
- Acceptance on touch controls: initiate a slide from low speed, sustain several
  doughnuts left and right, tighten/widen the circle with steering and throttle,
  transition through a figure-eight, and recover predictably to grip.
- Apply the same art of rally foundation and Diamond Is Unbreakable palette.
  This is a handling test space; the future social turnout remains separate scope.

v0.1: one coupe, arcade assisted driving, touch HUD, readable chase camera,
1–2 km night downhill with about six meaningful hairpins, sweeper/tunnel/overlook,
start/finish, angle/time drift score and combo, Android APK. Prove fun first.

v0.2: improve car, tire smoke, skid marks, headlights/brake lights, reflections,
road/tunnel lighting, audio, handling tuning, camera and effects. Feel like a game.

v0.3: compact city/industrial district, highway linking to mountain, garage,
basic events and free driving. City-to-mountain about 2–3 minutes. Small and
memorable beats huge and empty. Prove the driving loop.

Future districts: port warehouses, containers, service roads and wide drift
spaces; compact downtown/outskirts, parking and landmarks; highway/interchange
sweepers; mountain with 5–7 hairpins, tunnels and turnout; garage for selection,
tuning, customization and progression. Amber/sodium-like practical lighting,
cool shadows and selective reflective asphalt evoke the city's period atmosphere.

Later: cars, customization, tuning, routes, street races, rivals, crews,
reputation, money, unlocking and traffic. Police/chases much later. Progression:
explore → discover rival/event → drift/race → money/reputation → modify → unlock
harder districts/opponents → return to the mountain. Discovery lives in the world.

## Technical priorities
Order: driving feel, camera, stable 60 FPS, road layout, lighting, car
presentation, smoke/skids, environment detail. Scale internal resolution rather
than automatically using native tablet pixels. Provide scalable shadows,
reflections, vegetation, particle/smoke budget and post processing as they are
implemented. Investigate 90/120 FPS only after 60 FPS profiling.

## Delivery and verification gates
Back up source, this plan, README and development notes to private
Harshxda/touge-drift. Install Godot 4, matching export templates, Java, Android
SDK/build tools and ADB. Build controller, camera/touch, greybox, night pass,
optimize on Pad 7, then export/validate/install/launch/test the actual APK.

An export is not proof of playability. Check existence/nonzero size, ZIP integrity,
manifest/package, signing, compatible architecture, packaged scenes/resources,
script errors, install/launch on Android where possible, touch, driving,
drifting, camera, headlights/night rendering and crashes. Report untested items.

Acceptance: direct driving launch; accelerate/brake; touch steering; initiate
and sustain controlled drift; transition between corners; recover without
constant spins; use handbrake; complete downhill; receive score/combo feedback.
Camera stays usable. Mark v0.1 Playable only after Android acceptance testing.
Never build the full city or progression before drifting is fun. Never trade
frame rate for decoration, flood the mountain with sakura, or delay the core
for police/traffic. The milestone is: driving this one road is already fun.
