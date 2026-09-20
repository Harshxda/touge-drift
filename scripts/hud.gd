class_name TouchHUD
extends Control
signal reset_requested
signal quality_requested
signal mode_requested
var practice_mode := true
var car: DriftCar
var progress := 0.0
var finished := false
var fingers := {}
var regions := {}
var mouse_action := ""
var pad_device := -1
var pad_steer := 0.0
var pad_throttle := 0.0
var pad_brake := 0.0
var pad_handbrake := false
var input_focused := true
const STICK_DEADZONE := 0.15
var ink := Color("ebeee5")
var amber := Color("f1ba70")
var font := ThemeDB.fallback_font

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Input.joy_connection_changed.connect(_pad_connection_changed)

func _clear_pad() -> void:
	pad_steer = 0.0
	pad_throttle = 0.0
	pad_brake = 0.0
	pad_handbrake = false

func _pad_connection_changed(device: int, connected: bool) -> void:
	if not connected and device == pad_device:
		_clear_pad()
		pad_device = -1

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		input_focused = false
		fingers.clear()
		mouse_action = ""
		_clear_pad()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		input_focused = true

func _input(event: InputEvent) -> void:
	if not input_focused:
		return
	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		# Keep one active controller; disconnecting releases it for another pad.
		if pad_device != -1 and event.device != pad_device:
			return
		if event is InputEventJoypadMotion:
			if event.axis not in [JOY_AXIS_LEFT_X, JOY_AXIS_TRIGGER_LEFT, JOY_AXIS_TRIGGER_RIGHT]:
				return
			if pad_device == -1 and absf(event.axis_value) < STICK_DEADZONE:
				return
			pad_device = event.device
			match event.axis:
				JOY_AXIS_LEFT_X:
					pad_steer = signf(event.axis_value) * clampf((absf(event.axis_value) - STICK_DEADZONE) / (1.0 - STICK_DEADZONE), 0.0, 1.0)
				JOY_AXIS_TRIGGER_LEFT:
					pad_brake = clampf(event.axis_value, 0.0, 1.0)
				JOY_AXIS_TRIGGER_RIGHT:
					pad_throttle = clampf(event.axis_value, 0.0, 1.0)
		else:
			if event.button_index not in [JOY_BUTTON_A, JOY_BUTTON_Y, JOY_BUTTON_X]:
				return
			pad_device = event.device
			if event.button_index == JOY_BUTTON_A:
				pad_handbrake = event.pressed
			elif event.pressed:
				if event.button_index == JOY_BUTTON_X:
					mode_requested.emit()
				else:
					reset_requested.emit()
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			fingers[event.index] = action_at(event.position)
			_tap(fingers[event.index])
		else:
			fingers.erase(event.index)
	elif event is InputEventScreenDrag:
		fingers[event.index] = action_at(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		mouse_action = action_at(event.position) if event.pressed else ""
		if event.pressed:
			_tap(mouse_action)
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		reset_requested.emit()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_P:
		mode_requested.emit()

func _tap(action: String) -> void:
	if action == "mode":
		mode_requested.emit()
	if action == "reset":
		reset_requested.emit()
	if action == "quality":
		quality_requested.emit()

func action_at(pos: Vector2) -> String:
	for action in regions:
		if regions[action].has_point(pos):
			return action
	return ""

func held(action: String, key: Key) -> bool:
	return action in fingers.values() or mouse_action == action or Input.is_physical_key_pressed(key)

func _process(_dt: float) -> void:
	car.steer = float(held("right", KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(held("left", KEY_A) or Input.is_physical_key_pressed(KEY_LEFT))
	car.throttle = float(held("throttle", KEY_W) or Input.is_physical_key_pressed(KEY_UP))
	car.brake = float(held("brake", KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))
	car.handbrake = held("handbrake", KEY_SPACE)
	if absf(car.steer) < absf(pad_steer):
		car.steer = pad_steer
	car.throttle = maxf(car.throttle, pad_throttle)
	car.brake = maxf(car.brake, pad_brake)
	car.handbrake = car.handbrake or pad_handbrake
	if not input_focused:
		car.steer = 0.0
		car.throttle = 0.0
		car.brake = 0.0
		car.handbrake = false
	queue_redraw()

func _draw() -> void:
	var s := size
	var u := minf(s.x / 1440.0, s.y / 900.0)
	var w := 142 * u
	var h := 122 * u
	# Keep telemetry readable against both the yellow sky and the night road.
	draw_style_box(_panel(false), Rect2(Vector2(20,18)*u,Vector2(320,156)*u))
	draw_style_box(_panel(false), Rect2(Vector2(s.x/2-120*u,20*u),Vector2(235,78)*u))
	if practice_mode:
		draw_style_box(_panel(false), Rect2(Vector2(24,193)*u,Vector2(590,30)*u))
	if pad_device != -1:
		draw_style_box(_panel(false), Rect2(Vector2(24,172)*u,Vector2(1050,22)*u))
	regions = {"left": Rect2(28*u, s.y-h-28*u, w, h), "right": Rect2(184*u, s.y-h-28*u, w, h), "brake": Rect2(s.x-338*u, s.y-h-28*u, w, h), "throttle": Rect2(s.x-174*u, s.y-208*u, w, 180*u), "handbrake": Rect2(s.x-338*u, s.y-272*u, w, h), "reset": Rect2(s.x-170*u, 26*u, 140*u, 48*u), "quality": Rect2(s.x-340*u, 26*u, 150*u, 48*u), "mode": Rect2(s.x-340*u, 90*u, 310*u, 48*u)}
	var names := {"left":"◀", "right":"▶", "brake":"BRAKE", "throttle":"GAS", "handbrake":"HANDBRAKE", "reset":"RESET", "quality":"QUALITY", "mode":"GO DOWNHILL" if practice_mode else "PRACTICE LOT"}
	for action in regions:
		var rect: Rect2 = regions[action]
		var active: bool = action in fingers.values() or action == mouse_action
		draw_style_box(_panel(active), rect)
		draw_string(font, rect.position + Vector2(16*u, rect.size.y/2+8*u), names[action], HORIZONTAL_ALIGNMENT_LEFT, -1, int((18 if action == "handbrake" else 23)*u), amber if active else ink)
	draw_string(font, Vector2(32, 48)*u, "TOUGE / DRIFT", HORIZONTAL_ALIGNMENT_LEFT, -1, int(26*u), ink)
	draw_string(font, Vector2(32, 80)*u, "KASUMI / PRACTICE" if practice_mode else "KASUMI / DOWNHILL", HORIZONTAL_ALIGNMENT_LEFT, -1, int(16*u), amber)
	draw_string(font, Vector2(32, 133)*u, "%03d  KM/H  %s" % [car.speed * 3.6, "R" if car.gear == 0 else str(car.gear)], HORIZONTAL_ALIGNMENT_LEFT, -1, int(34*u), ink)
	draw_string(font, Vector2(s.x/2-100*u, 52*u), "%06d" % (car.banked + car.score), HORIZONTAL_ALIGNMENT_LEFT, -1, int(38*u), ink)
	draw_string(font, Vector2(s.x/2-100*u, 83*u), "x%.1f   /   %02d°" % [car.combo, absf(rad_to_deg(car.slip))], HORIZONTAL_ALIGNMENT_LEFT, -1, int(21*u), amber)
	draw_rect(Rect2(32*u, 154*u, 210*u, 3*u), Color(1,1,1,0.15))
	draw_rect(Rect2(32*u, 154*u, 210*u*progress, 3*u), amber)
	if pad_device != -1:
		draw_string(font, Vector2(32, 185)*u, "PAD: LEFT STICK / RT·R2 GAS / LT·L2 BRAKE / A·× E-BRAKE / Y·△ RESET / X·□ MODE", HORIZONTAL_ALIGNMENT_LEFT, -1, int(15*u), ink)
	if practice_mode:
		draw_string(font, Vector2(32, 212)*u, "STEER + GAS, TAP HANDBRAKE. RELEASE TO HOLD THE SLIDE.", HORIZONTAL_ALIGNMENT_LEFT, -1, int(15*u), amber)
	if finished:
		draw_string(font, Vector2(s.x/2-200*u, s.y*0.36), "DOWNHILL COMPLETE", HORIZONTAL_ALIGNMENT_LEFT, -1, int(34*u), amber)
		draw_string(font, Vector2(s.x/2-200*u, s.y*0.36+38*u), "Reset for another run", HORIZONTAL_ALIGNMENT_LEFT, -1, int(23*u), ink)
	elif car.crashed:
		draw_string(font, Vector2(s.x/2-120*u, 120*u), "COMBO LOST", HORIZONTAL_ALIGNMENT_LEFT, -1, int(23*u), amber)

func _panel(active: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.12, 0.16, 0.82 if active else 0.55)
	style.border_color = amber if active else Color(0.8, 0.87, 0.9, 0.35)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	return style
