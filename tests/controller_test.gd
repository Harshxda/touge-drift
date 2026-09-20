extends SceneTree
var failed := false
var resets := 0
var mode_changes := 0
func check(ok: bool, label: String) -> void:
	if not ok:
		failed = true
		push_error(label)
	else:
		print("PASS: ", label)
func motion(hud: TouchHUD, axis: JoyAxis, value: float) -> void:
	var event := InputEventJoypadMotion.new()
	event.device = 7
	event.axis = axis
	event.axis_value = value
	hud._input(event)
func button(hud: TouchHUD, index: JoyButton, pressed: bool) -> void:
	var event := InputEventJoypadButton.new()
	event.device = 7
	event.button_index = index
	event.pressed = pressed
	hud._input(event)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var car := DriftCar.new()
	var hud := TouchHUD.new()
	hud.car = car
	root.add_child(hud)
	hud.set_process(false)
	hud.reset_requested.connect(func(): resets += 1)
	hud.mode_requested.connect(func(): mode_changes += 1)
	motion(hud, JOY_AXIS_LEFT_X, 0.1)
	hud._process(0)
	check(car.steer == 0, "Stick drift suppressed")
	motion(hud, JOY_AXIS_LEFT_X, -0.575)
	motion(hud, JOY_AXIS_TRIGGER_RIGHT, 0.4)
	motion(hud, JOY_AXIS_TRIGGER_LEFT, 0.2)
	button(hud, JOY_BUTTON_A, true)
	hud._process(0)
	check(is_equal_approx(car.steer, -0.5) and is_equal_approx(car.throttle, 0.4) and is_equal_approx(car.brake, 0.2) and car.handbrake, "Analog steering, both triggers and handbrake combine")
	button(hud, JOY_BUTTON_A, false)
	hud._process(0)
	check(not car.handbrake and is_equal_approx(car.throttle, 0.4), "Handbrake release preserves throttle")
	button(hud, JOY_BUTTON_Y, true)
	button(hud, JOY_BUTTON_Y, false)
	check(resets == 1, "Reset fires on press only")
	button(hud, JOY_BUTTON_X, true)
	button(hud, JOY_BUTTON_X, false)
	check(mode_changes == 1, "X / Square switches practice and downhill on press")
	hud._pad_connection_changed(7, false)
	hud._process(0)
	check(car.steer == 0 and car.throttle == 0 and car.brake == 0 and hud.pad_device == -1, "Disconnect clears controller")
	motion(hud, JOY_AXIS_TRIGGER_RIGHT, 1)
	hud._notification(Control.NOTIFICATION_APPLICATION_FOCUS_OUT)
	motion(hud, JOY_AXIS_TRIGGER_RIGHT, 1)
	hud._process(0)
	check(car.throttle == 0, "Focus loss clears and blocks input")
	hud._notification(Control.NOTIFICATION_APPLICATION_FOCUS_IN)
	hud._process(0)
	check(car.throttle == 0, "Focus return does not restore stale throttle")
	motion(hud, JOY_AXIS_LEFT_X, 1)
	hud._process(0)
	check(car.steer == 1, "Fresh input works after focus return")
	hud.free()
	car.free()
	quit(1 if failed else 0)
