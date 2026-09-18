class_name TougeTrack
extends Node3D

var points := PackedVector3Array()
var distances := PackedFloat32Array()
var total_length := 0.0
const WIDTH := 11.0
var asphalt := material("252f39")
var concrete := material("52606a")
var stripe := material("c9b77e")

static func material(hex: String) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(hex)
	m.roughness = 0.8
	return m

func _ready() -> void:
	# Six alternating semicircular hairpins linked by mountain traverses.
	var path := PackedVector2Array([Vector2(0, 0)])
	var cursor := Vector2(0, 0)
	var direction := Vector2(0, -1)
	for corner in range(6):
		for step in range(35):
			cursor += direction * 5.0
			path.append(cursor)
		var turn := 1.0 if corner % 2 == 0 else -1.0
		for step in range(36):
			direction = direction.rotated(turn * PI / 36)
			cursor += direction * (PI * 24.0 / 36)
			path.append(cursor)
	for step in range(30):
		cursor += direction * 5.0
		path.append(cursor)
	for i in range(path.size()):
		if i > 0:
			total_length += path[i].distance_to(path[i - 1])
		distances.append(total_length)
		points.append(Vector3(path[i].x, 90.0 - total_length * 0.048, path[i].y))
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(points.size() - 1):
		var a := points[i]
		var b := points[i + 1]
		var right_a := tangent(i).cross(Vector3.UP).normalized() * WIDTH / 2
		var right_b := tangent(i + 1).cross(Vector3.UP).normalized() * WIDTH / 2
		for vertex in [a - right_a, b - right_b, a + right_a, a + right_a, b - right_b, b + right_b]:
			surface.add_vertex(vertex)
		for side in [-1.0, 1.0]:
			var offset_a: Vector3 = right_a * side
			var offset_b: Vector3 = right_b * side
			beam(a + offset_a + Vector3.UP * 0.7, b + offset_b + Vector3.UP * 0.7, Vector2(0.20, 0.65), concrete, true)
		if i % 3 == 0:
			beam(a + Vector3.UP * 0.025, b + Vector3.UP * 0.025, Vector2(0.12, 0.025), stripe)
	surface.generate_normals()
	var mesh := MeshInstance3D.new()
	mesh.mesh = surface.commit()
	mesh.material_override = asphalt
	add_child(mesh)
	mesh.create_trimesh_collision()
	_decorate()
	_terrain()
	_batch_boxes()

func tangent(index: int) -> Vector3:
	return (points[mini(index + 1, points.size() - 1)] - points[maxi(0, index - 1)]).normalized()

func beam(a: Vector3, b: Vector3, size: Vector2, mat: Material, collision := false) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(size.x, size.y, a.distance_to(b) + 0.05)
	mesh.mesh = box
	mesh.material_override = mat
	add_child(mesh)
	mesh.position = (a + b) / 2
	mesh.look_at(b, Vector3.RIGHT if absf((b-a).normalized().dot(Vector3.UP)) > 0.99 else Vector3.UP)
	if collision:
		mesh.create_trimesh_collision()

func _decorate() -> void:
	var forest := material("182e30")
	var blossom := material("b8899b")
	var rng := RandomNumberGenerator.new()
	rng.seed = 4182
	var trees := MultiMesh.new()
	trees.transform_format = MultiMesh.TRANSFORM_3D
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 3.8
	cone.height = 13
	cone.radial_segments = 5
	trees.mesh = cone
	trees.instance_count = 360
	for i in range(360):
		var index := rng.randi_range(0, points.size() - 1)
		var side := -1.0 if i % 2 == 0 else 1.0
		var p := points[index] + tangent(index).cross(Vector3.UP).normalized() * rng.randf_range(12, 23) * side
		p.y += 3
		trees.set_instance_transform(i, Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * rng.randf_range(0.7, 1.5)), p))
	var instance := MultiMeshInstance3D.new()
	instance.multimesh = trees
	instance.material_override = forest
	add_child(instance)
	for i in range(0, points.size() - 1, 22):
		var p := points[i] + tangent(i).cross(Vector3.UP) * 6
		beam(p, p + Vector3.UP * 7, Vector2(0.14, 0.14), concrete)
		var light := OmniLight3D.new()
		light.position = p + Vector3.UP * 6
		light.light_color = Color("ffb76f")
		light.light_energy = 2.2
		light.omni_range = 19
		light.distance_fade_enabled = true
		light.distance_fade_begin = 70
		add_child(light)
	# Covered gallery on the traverse before the final hairpin.
	for i in range(365, 384):
		var a := points[i]
		var b := points[i + 1]
		beam(a + Vector3.UP * 6, b + Vector3.UP * 6, Vector2(13, 0.7), concrete)
		for side in [-1.0, 1.0]:
			var r: Vector3 = tangent(i).cross(Vector3.UP) * 6 * side
			beam(a + r, a + r + Vector3.UP * 6, Vector2(0.6, 0.6), concrete)
	for i in range(7):
		var p := points[430] + Vector3(12 + i * 3, 3, -10 + i % 3 * 5)
		var tree := MeshInstance3D.new()
		var crown := SphereMesh.new()
		crown.radius = 3
		crown.height = 5
		crown.radial_segments = 8
		crown.rings = 4
		tree.mesh = crown
		tree.material_override = blossom
		tree.position = p
		add_child(tree)
		beam(p - Vector3.UP * 5, p, Vector2(0.4, 0.4), concrete)
	for i in range(24):
		var mountain := MeshInstance3D.new()
		var peak := CylinderMesh.new()
		peak.top_radius = 0
		peak.bottom_radius = rng.randf_range(70, 140)
		peak.height = rng.randf_range(100, 220)
		peak.radial_segments = 5
		mountain.mesh = peak
		mountain.material_override = forest
		mountain.position = Vector3(rng.randf_range(-350, 650), -65, rng.randf_range(-500, 250))
		add_child(mountain)
	var city := material("e7b96d")
	city.emission_enabled = true
	city.emission = Color("e7b96d")
	for i in range(80):
		var p := Vector3(rng.randf_range(-300, 650), -50, -450 - rng.randf_range(0, 200))
		beam(p, p + Vector3.RIGHT * 2, Vector2(1.5, 1.5), city)

func _batch_boxes() -> void:
	var groups := {}
	for child in get_children():
		if child is MeshInstance3D and child.mesh is BoxMesh:
			var mat: Material = child.material_override
			if not groups.has(mat):
				groups[mat] = []
			groups[mat].append(child)
	for mat in groups:
		var batch := MultiMesh.new()
		batch.transform_format = MultiMesh.TRANSFORM_3D
		var unit := BoxMesh.new()
		unit.size = Vector3.ONE
		batch.mesh = unit
		batch.instance_count = groups[mat].size()
		for i in range(groups[mat].size()):
			var source: MeshInstance3D = groups[mat][i]
			batch.set_instance_transform(i, source.transform * Transform3D(Basis.IDENTITY.scaled(source.mesh.size), Vector3.ZERO))
			source.visible = false
		var instance := MultiMeshInstance3D.new()
		instance.multimesh = batch
		instance.material_override = mat
		add_child(instance)

func _terrain() -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(points.size() - 1):
		var a := points[i] - Vector3.UP * 0.25
		var b := points[i + 1] - Vector3.UP * 0.25
		var ra := tangent(i).cross(Vector3.UP).normalized() * 27
		var rb := tangent(i + 1).cross(Vector3.UP).normalized() * 27
		for vertex in [a-ra, b-rb, a+ra, a+ra, b-rb, b+rb]:
			surface.add_vertex(vertex)
	surface.generate_normals()
	var land := MeshInstance3D.new()
	land.mesh = surface.commit()
	land.material_override = material("233633")
	add_child(land)
	# A parking apron gives the launch area room behind the car.
	var start := points[0]
	beam(start + Vector3(0,-0.2,22), start + Vector3(0,-0.2,-25), Vector2(24,0.4), asphalt, true)
	var finish := points[points.size()-1]
	beam(finish + Vector3(0,-0.2,15), finish + Vector3(0,-0.2,-15), Vector2(24,0.4), asphalt, true)
	var bulb := material("ffe0a0")
	bulb.emission_enabled = true
	bulb.emission = Color("ffd59a")
	bulb.emission_energy_multiplier = 3
	for i in range(0, points.size()-1, 22):
		var p := points[i] + tangent(i).cross(Vector3.UP) * 6 + Vector3.UP * 6
		beam(p, p - tangent(i).cross(Vector3.UP) * 1.8, Vector2(0.2,0.15), bulb)
