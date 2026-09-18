extends SceneTree
var failed := false
func check(value: bool, message: String) -> void:
	if not value:
		failed = true
		push_error(message)
	else:
		print("PASS: ", message)

func _initialize() -> void:
	call_deferred("run")

func frames(count: int) -> void:
	for i in range(count):
		await physics_frame

func run() -> void:
	var world := Node3D.new()
	root.add_child(world)
	var ground := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2000, 1, 2000)
	shape.shape = box
	shape.position.y = -0.5
	ground.add_child(shape)
	world.add_child(ground)
	var car := DriftCar.new()
	world.add_child(car)
	car.position.y = 0.1
	await frames(30)
	check(car.is_on_floor(), "Vehicle settles on road")
	car.throttle = 1
	await frames(180)
	check(car.speed > 20, "Throttle accelerates above 72 km/h")
	var previous_speed := car.speed
	car.throttle = 0
	car.brake = 1
	await frames(40)
	check(car.speed < previous_speed - 8, "Brake slows vehicle")
	car.brake = 0
	car.throttle = 0.8
	car.steer = 0.6
	car.handbrake = true
	await frames(22)
	car.handbrake = false
	await frames(60)
	print("DRIFT angle=", rad_to_deg(car.slip), " speed=", car.speed, " score=", car.score)
	check(car.drifting, "Handbrake initiates drift")
	check(absf(car.slip) > deg_to_rad(12) and absf(car.slip) < deg_to_rad(70), "Assist sustains scoreable drift angle")
	check(car.score > 0, "Drift awards score")
	car.steer = 0
	await frames(180)
	check(absf(car.slip) < deg_to_rad(10), "Assist recovers to grip")
	check(car.banked > 0, "Combo banks after recovery")
	car.throttle = 0
	car.brake = 1
	await frames(240)
	check(car.velocity.dot(-car.global_basis.z) < -1, "Brake reverses after stopping")
	var hud := TouchHUD.new()
	hud.car = car
	root.add_child(hud)
	hud.set_process(false)
	hud.regions = {"left": Rect2(0,0,100,100), "throttle": Rect2(200,0,100,100)}
	for i in range(2):
		var touch := InputEventScreenTouch.new()
		touch.index = i
		touch.pressed = true
		touch.position = Vector2(50 + i*200, 50)
		hud._input(touch)
	check(hud.held("left", KEY_A) and hud.held("throttle", KEY_W), "Independent steering and throttle touches")
	var release := InputEventScreenTouch.new()
	release.index = 0
	hud._input(release)
	check(not hud.held("left", KEY_A) and hud.held("throttle", KEY_W), "Releasing steering preserves throttle")
	hud._notification(Control.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(hud.fingers.is_empty(), "Focus loss clears held touches")
	quit(1 if failed else 0)
