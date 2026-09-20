extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var model := CoupeVisual.new()
	root.add_child(model)
	await process_frame
	var failed := false
	var meshes := 0
	for child in model.get_children():
		if child is MeshInstance3D:
			meshes += 1
			var arrays: Array = child.mesh.surface_get_arrays(0)
			var referenced := {}
			for index in arrays[Mesh.ARRAY_INDEX]:
				referenced[index] = true
			if referenced.size() != arrays[Mesh.ARRAY_VERTEX].size():
				failed = true
				push_error("Merged car contains unreferenced panel vertices")
	if meshes != 4:
		failed = true
	if not failed:
		print("PASS: All car panels survive mesh merging; four body materials")
	model.free()
	quit(1 if failed else 0)
