extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	Engine.max_fps = 0
	var world: Node3D = load("res://scenes/world.tscn").instantiate()
	root.add_child(world)
	world.practice_mode = false
	world.restart()
	world.hud.set_process(false)
	var car: DriftCar = world.car
	var max_slip := 0.0
	var collisions := 0
	for frame in range(18000):
		var index: int = mini(world.nearest + 3, world.track.points.size()-1)
		var target: Vector3 = world.track.points[index] - car.position
		var yaw := atan2(-target.x, -target.z)
		var error := wrapf(yaw - car.rotation.y, -PI, PI)
		car.steer = clampf(-error * 2.4, -1, 1)
		var target_speed := 10.0 if absf(error) > 0.22 else 17.0
		car.throttle = 0.7 if car.speed < target_speed else 0.0
		car.brake = 0.3 if car.speed > target_speed + 1 else 0.0
		await physics_frame
		max_slip = maxf(max_slip, absf(car.slip))
		if car.crashed:
			collisions += 1
		if world.hud.finished:
			print("PASS: Full downhill route completed. length=", world.track.total_length, "m physics_frames=", frame, " collision_frames=", collisions, " max_angle=", rad_to_deg(max_slip))
			quit(0)
			return
	print("FAIL: downhill incomplete, progress=", world.hud.progress, " car=", car.position)
	quit(1)
