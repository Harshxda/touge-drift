extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	var scene: Node3D = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	await create_timer(3).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("user://preview.png")
	print("RENDER_CAPTURE_COMPLETE")
	quit()
