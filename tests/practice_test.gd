extends SceneTree
var failed := false
func check(ok: bool, label: String) -> void:
	if not ok:
		failed = true
		push_error(label)
	else:
		print("PASS: ",label)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	Engine.max_fps = 0
	var world: Node3D = load("res://scenes/world.tscn").instantiate()
	root.add_child(world)
	world.hud.set_process(false)
	var car: DriftCar = world.car
	var feedback: DrivingFeedback
	for child in world.get_children():
		if child is DrivingFeedback:
			feedback = child
	check(feedback != null and feedback.marks.instance_count == 768, "Skid trail has bounded geometry")
	for player in [feedback.engine,feedback.tires]:
		check(absf(player.stream.get_length()-1.0) < 0.01 and player.stream.loop_end == player.stream.mix_rate, "Audio loop length uses sample offsets")
	check(world.practice_mode and world.hud.practice_mode, "Game starts in practice")
	for side in [-1.0,1.0]:
		world.restart()
		car.steer = 0
		car.throttle = 0
		car.brake = 0
		car.handbrake = false
		for frame in range(30):
			await physics_frame
		check(car.is_on_floor(), "Practice spawn has ground contact")
		car.throttle = 0.85
		for frame in range(65):
			await physics_frame
		car.steer = side * 0.8
		car.handbrake = true
		for frame in range(16):
			await physics_frame
		car.handbrake = false
		car.throttle = 0.65
		var rotation_total := 0.0
		var previous_yaw := car.rotation.y
		var drift_frames := 0
		var collision_frames := 0
		for frame in range(1200):
			await physics_frame
			rotation_total += absf(wrapf(car.rotation.y-previous_yaw,-PI,PI))
			previous_yaw = car.rotation.y
			if car.drifting and absf(car.slip) > deg_to_rad(12) and car.is_on_floor():
				drift_frames += 1
			if car.crashed:
				collision_frames += 1
		print("DOUGHNUT side=",side," turns=",rotation_total/TAU," drift_frames=",drift_frames," contacts=",collision_frames," position=",car.position," speed=",car.speed," slip=",rad_to_deg(car.slip))
		check(rotation_total > TAU*2 and drift_frames > 900 and collision_frames == 0, "Several sustained doughnuts without hitting obstacles")
		check(world.practice_mode and not world.hud.finished and world.hud.progress == 0, "Practice does not advance or finish downhill")
	world.restart()
	check(car.position.distance_to(TougeTrack.PRACTICE_SPAWN + Vector3.UP*0.4) < 0.01, "Reset returns to parking start")
	world.toggle_mode()
	check(not world.practice_mode and car.position.z == 0, "Mode switch starts downhill")
	world.toggle_mode()
	check(world.practice_mode, "Mode switch returns to practice")
	car.reset_at(Vector3(0,90,-3),0)
	await physics_frame
	await physics_frame
	check(not world.practice_mode, "Driving through exit starts downhill")
	world.queue_free()
	await process_frame
	quit(1 if failed else 0)
