extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func save_capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/" + name + ".png")
func capture() -> void:
	var scene: Node3D = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	await create_timer(3).timeout
	scene.hud.queue_redraw()
	await save_capture("preview")
	scene.hud.set_process(false)
	scene.car.throttle = 0.85
	for i in range(65):
		await physics_frame
	scene.car.steer = 0.8
	scene.car.handbrake = true
	for i in range(16):
		await physics_frame
	scene.car.handbrake = false
	scene.car.throttle = 0.65
	for i in range(180):
		await physics_frame
	scene.hud.queue_redraw()
	await save_capture("practice-drift")
	scene.practice_mode = false
	scene.restart()
	scene.car.throttle = 0
	scene.car.steer = 0
	scene.nearest = 38
	scene.checkpoint = 38
	scene._respawn(38)
	await create_timer(1).timeout
	scene.hud.queue_redraw()
	await save_capture("downhill")
	scene.queue_free()
	await create_timer(0.25).timeout
	print("RENDER_CAPTURE_COMPLETE")
	quit()
