class_name TougeTrack
extends Node3D

var points := PackedVector3Array()
var distances := PackedFloat32Array()
var total_length := 0.0
const WIDTH := 11.0
const PRACTICE_SPAWN := Vector3(0, 90, 105)
const PRACTICE_BOUNDS := Rect2(-56, 8, 112, 128)
var asphalt := material("555466")
var concrete := material("b0a3b6")
var stripe := material("eddbad")

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
	_landmarks()
	_practice_area()
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
	var forest := material("8d72a9")
	var blossom := material("d7a5bf")
	var rng := RandomNumberGenerator.new()
	rng.seed = 4182
	var trees := MultiMesh.new()
	trees.transform_format = MultiMesh.TRANSFORM_3D
	var cone := CylinderMesh.new()
	cone.top_radius = 0.5
	cone.bottom_radius = 3.8
	cone.height = 9
	cone.radial_segments = 5
	trees.mesh = cone
	trees.instance_count = 360
	for i in range(360):
		var index := rng.randi_range(0, points.size() - 1)
		var side := -1.0 if i % 2 == 0 else 1.0
		var p := points[index] + tangent(index).cross(Vector3.UP).normalized() * rng.randf_range(12, 23) * side
		p.y += 3
		trees.set_instance_transform(i, Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * rng.randf_range(0.65, 1.1)), p))
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
		mountain.material_override = material("827391")
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
	land.material_override = material("83a58b")
	add_child(land)
	# A parking apron gives the launch area room behind the car.
	var start := points[0]
	beam(start + Vector3(0,-0.2,12), start + Vector3(0,-0.2,0), Vector2(24,0.4), asphalt, true)
	var finish := points[points.size()-1]
	beam(finish + Vector3(0,-0.2,15), finish + Vector3(0,-0.2,-15), Vector2(24,0.4), asphalt, true)
	var bulb := material("ffe0a0")
	bulb.emission_enabled = true
	bulb.emission = Color("ffd59a")
	bulb.emission_energy_multiplier = 3
	for i in range(0, points.size()-1, 22):
		var p := points[i] + tangent(i).cross(Vector3.UP) * 6 + Vector3.UP * 6
		beam(p, p - tangent(i).cross(Vector3.UP) * 1.8, Vector2(0.2,0.15), bulb)

func _landmarks() -> void:
	var ink := material("414456")
	var peach := material("ce9f90")
	var roof := material("546477")
	var warm := material("ffd395")
	warm.emission_enabled = true
	warm.emission = Color("ffd395")
	warm.emission_energy_multiplier = 1.5
	# Outside shoulders: drainage, reflectors, utility cables and corner markers.
	for i in range(0,points.size()-2,4):
		var r := tangent(i).cross(Vector3.UP).normalized()
		beam(points[i]+r*5.15+Vector3.UP*0.02,points[i+1]+r*5.15+Vector3.UP*0.02,Vector2(0.23,0.03),ink)
		for side in [-1.0,1.0]:
			var p: Vector3 = points[i]+r*5.5*side+Vector3.UP*0.76
			beam(p,p+tangent(i)*0.32,Vector2(0.24,0.08),warm)
	for corner in range(6):
		var index := corner*71+49
		var p := points[index]+tangent(index).cross(Vector3.UP)*8
		beam(p,p+Vector3.UP*2.8,Vector2(0.13,0.13),ink)
		var sign := Label3D.new()
		sign.text = "‹ ‹ ‹" if corner%2 == 0 else "› › ›"
		sign.font_size = 100
		sign.pixel_size = 0.018
		sign.modulate = Color("ffe3a3")
		sign.position = p+Vector3.UP*2.8
		sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		add_child(sign)
	for i in range(0,points.size()-23,22):
		var a := points[i]+tangent(i).cross(Vector3.UP)*6+Vector3.UP*7
		var b := points[i+22]+tangent(i+22).cross(Vector3.UP)*6+Vector3.UP*7
		var mid := (a+b)/2-Vector3.UP*0.8
		beam(a,mid,Vector2(0.035,0.035),ink)
		beam(mid,b,Vector2(0.035,0.035),ink)
	# Summit rest stop: one pavilion and two machines, kept clear of the road.
	var p := points[0]+Vector3(-16,0,5)
	beam(p,p+Vector3.UP*3.0,Vector2(5.5,4.0),peach)
	beam(p+Vector3(-3,3.2,0),p+Vector3(3,3.2,0),Vector2(4.8,0.25),roof)
	for offset in [0.0,1.6]:
		var machine: Vector3 = points[0]+Vector3(8+offset,0,3)
		beam(machine,machine+Vector3.UP*2,Vector2(1.15,0.85),peach)
		beam(machine+Vector3(-0.4,1.3,-0.46),machine+Vector3(0.4,1.3,-0.46),Vector2(0.08,0.8),warm)
	# Small distant houses establish inhabited lower slopes without building a city.
	for i in range(6):
		var index := 300+i*23
		var base := points[index]+tangent(index).cross(Vector3.UP)*18-Vector3.UP*0.3
		beam(base,base+Vector3.UP*3.3,Vector2(5.0,5.5),peach)
		beam(base+Vector3(-3,3.5,0),base+Vector3(3,3.5,0),Vector2(6,0.25),roof)
		for x in [-1.3,1.3]:
			var window := base+Vector3(x,2,-2.79)
			beam(window,window+Vector3.RIGHT*0.75,Vector2(0.04,0.9),warm)
	# Warm tunnel fixtures mark the descent into night.
	for i in range(366,383,4):
		beam(points[i]+Vector3(-3,5.5,0),points[i]+Vector3(3,5.5,0),Vector2(0.2,0.12),warm)

func _practice_area() -> void:
	# Flat 112 x 128 m pad, with a clear connector to the original road start.
	beam(Vector3(0,89.8,8), Vector3(0,89.8,136), Vector2(112,0.4), asphalt, true)
	var paint := material("f2df9d")
	var mint := material("97cfb2")
	var lavender := material("9b79b1")
	for x in [-57.0,57.0]:
		beam(Vector3(x,90.4,8),Vector3(x,90.4,137),Vector2(0.7,0.8),concrete,true)
	beam(Vector3(-57,90.4,137),Vector3(57,90.4,137),Vector2(0.7,0.8),concrete,true)
	for x in [-34.0,34.0]:
		beam(Vector3(x,90.4,8),Vector3(signf(x)*56,90.4,8),Vector2(0.7,0.8),concrete,true)
	for center in [Vector3(-22,90.03,58),Vector3(22,90.03,58)]:
		for radius in [10.0,18.0]:
			for i in range(96):
				var a := TAU*i/96
				var b := TAU*(i+1)/96
				beam(center+Vector3(cos(a)*radius,0,sin(a)*radius),center+Vector3(cos(b)*radius,0,sin(b)*radius),Vector2(0.12,0.015),paint)
	for x in range(-48,49,8):
		beam(Vector3(x,90.03,121),Vector3(x,90.03,132),Vector2(0.12,0.015),paint)
	beam(Vector3(-48,90.03,121),Vector3(48,90.03,121),Vector2(0.12,0.015),paint)
	# Painted arrow points to the gap and the downhill; all props stay on the edge.
	beam(Vector3(0,90.03,27),Vector3(0,90.03,13),Vector2(0.35,0.015),mint)
	for x in [-3.0,3.0]:
		beam(Vector3(x,90.03,18),Vector3(0,90.03,13),Vector2(0.35,0.015),mint)
	for side in [-1.0,1.0]:
		for z in [25,50,75,100,125]:
			var base := Vector3(side*63,89,z)
			beam(base,base+Vector3.UP*6,Vector2(0.5,0.5),concrete)
			var crown := MeshInstance3D.new()
			var mesh := SphereMesh.new()
			mesh.radius = 4.5
			mesh.height = 7
			mesh.radial_segments = 7
			mesh.rings = 3
			crown.mesh = mesh
			crown.material_override = lavender
			crown.position = base+Vector3.UP*7
			add_child(crown)
	var sign := Label3D.new()
	sign.text = "KASUMI / PRACTICE\nDOUGHNUTS  ·  FIGURE EIGHTS\n↓ DOWNHILL"
	sign.font_size = 72
	sign.pixel_size = 0.018
	sign.position = Vector3(-19,94,10)
	sign.modulate = Color("f2df9d")
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(sign)
