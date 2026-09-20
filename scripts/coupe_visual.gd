class_name CoupeVisual
extends Node3D
## Original R14 mesh: shaped panels, open arches and a tapered glasshouse.
var wheels: Array[Node3D] = []
var paint := mat("b3cfc2", 0.32, 0.38)
var glass := mat("253447", 0.2, 0.42)
var trim := mat("202731", 0.65)
var alloy := mat("c9bd9f", 0.3, 0.7)

static func mat(color: String, roughness: float, metallic := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(color)
	m.roughness = roughness
	m.metallic = metallic
	return m

func _ready() -> void:
	# Body belt: nose, hood, shoulders and tapered rear deck.
	var sections := [Vector3(0.79,0.64,-2.24), Vector3(0.92,0.78,-1.75), Vector3(0.96,0.86,-0.7), Vector3(0.96,0.87,0.75), Vector3(0.92,0.82,1.55), Vector3(0.82,0.68,2.20)]
	for i in range(sections.size()-1):
		var a: Vector3 = sections[i]
		var b: Vector3 = sections[i+1]
		quad(Vector3(-a.x,a.y,a.z),Vector3(a.x,a.y,a.z),Vector3(b.x,b.y,b.z),Vector3(-b.x,b.y,b.z),paint)
	# Side panels follow the wheel-arch cutouts instead of covering the tires.
	for side in [-1.0,1.0]:
		for i in range(88):
			var za := -2.24 + i * 4.44 / 88
			var zb := -2.24 + (i+1) * 4.44 / 88
			var a := profile(za,sections)
			var b := profile(zb,sections)
			quad(Vector3(a.x*side,a.y,za),Vector3(b.x*side,b.y,zb),Vector3(b.x*side,arch(zb),zb),Vector3(a.x*side,arch(za),za),paint)
		# Door seam, rocker and flush handles.
		box(Vector3(0.018,0.02,1.36),Vector3(side*0.967,0.71,0.12),trim)
		box(Vector3(0.02,0.035,0.18),Vector3(side*0.967,0.79,0.55),alloy)
		box(Vector3(0.08,0.09,1.7),Vector3(side*0.94,0.27,0),paint)
		box(Vector3(0.19,0.10,0.25),Vector3(side*0.91,0.97,-0.62),paint)
	# Slanted windshield, rear screen and side glass. Roof remains painted.
	var fl := Vector3(-0.79,0.87,-0.76)
	var fr := Vector3(0.79,0.87,-0.76)
	var tl := Vector3(-0.64,1.32,-0.12)
	var tr := Vector3(0.64,1.32,-0.12)
	var bl := Vector3(-0.65,1.29,0.66)
	var br := Vector3(0.65,1.29,0.66)
	var rl := Vector3(-0.8,0.86,1.35)
	var rr := Vector3(0.8,0.86,1.35)
	quad(fl,fr,tr,tl,glass)
	quad(tl,tr,br,bl,paint)
	quad(bl,br,rr,rl,glass)
	quad(fl,tl,bl,rl,glass)
	quad(fr,rr,br,tr,glass)
	for pair in [[fl,tl],[fr,tr],[tl,bl],[tr,br],[bl,rl],[br,rr],[fl,rl],[fr,rr]]:
		bar(pair[0],pair[1],0.047,paint)
	for side in [-1.0,1.0]:
		bar(Vector3(side*0.665,1.29,0.47),Vector3(side*0.8,0.88,0.55),0.055,paint)
	# Sculpted bumper faces and dark apertures.
	for z in [-2.24,2.20]:
		var width := 0.79 if z < 0 else 0.82
		quad(Vector3(-width,0.64,z),Vector3(width,0.64,z),Vector3(width*0.96,0.29,z),Vector3(-width*0.96,0.29,z),paint)
		box(Vector3(1.52,0.075,0.15),Vector3(0,0.29,z),trim)
	box(Vector3(0.85,0.16,0.025),Vector3(0,0.43,-2.25),trim)
	box(Vector3(0.36,0.15,0.025),Vector3(0,0.47,2.22),alloy)
	# Compact deck lip with separate supports, not a solid rear block.
	for side in [-1.0,1.0]:
		box(Vector3(0.06,0.16,0.12),Vector3(side*0.57,0.90,1.86),trim)
	box(Vector3(1.76,0.055,0.27),Vector3(0,0.99,1.86),paint)
	for x in [-0.93,0.93]:
		for z in [-1.35,1.35]:
			var axle := Node3D.new()
			axle.position = Vector3(x,0.36,z)
			add_child(axle)
			wheels.append(axle)
			cylinder(axle,0.35,0.26,trim)
			cylinder(axle,0.245,0.272,alloy)
			cylinder(axle,0.19,0.278,trim)
			for spoke in range(6):
				var arm := MeshInstance3D.new()
				var shape := BoxMesh.new()
				shape.size = Vector3(0.286,0.038,0.42)
				arm.mesh = shape
				arm.rotation.x = spoke*PI/6
				arm.material_override = alloy
				axle.add_child(arm)
			cylinder(axle,0.065,0.29,alloy)
	box(Vector3(0.14,0.14,0.23),Vector3(-0.57,0.33,2.28),alloy)
	_merge_panels()

func profile(z: float, sections: Array) -> Vector3:
	for i in range(sections.size()-1):
		if z <= sections[i+1].z:
			return sections[i].lerp(sections[i+1],inverse_lerp(sections[i].z,sections[i+1].z,z))
	return sections.back()

func arch(z: float) -> float:
	var distance := minf(absf(z-1.35),absf(z+1.35))
	return 0.36 + sqrt(maxf(0,0.43*0.43-distance*distance)) if distance < 0.43 else 0.29

func quad(a: Vector3,b: Vector3,c: Vector3,d: Vector3,material: Material) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for v in [a,b,c,a,c,d]:
		surface.add_vertex(v)
	surface.generate_normals()
	# All merged surfaces must be indexed, including these custom panels.
	# Mixing indexed BoxMesh parts with unindexed panels drops panel triangles.
	surface.index()
	var instance := MeshInstance3D.new()
	instance.mesh = surface.commit()
	# Panels are thin shells; render both faces consistently.
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	instance.material_override = material
	add_child(instance)

func box(size: Vector3, pos: Vector3, material: Material) -> void:
	var instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.position = pos
	instance.material_override = material
	add_child(instance)

func bar(a: Vector3,b: Vector3,width: float,material: Material) -> void:
	box(Vector3(width,width,a.distance_to(b)),(a+b)/2,material)
	get_child(-1).look_at(b,Vector3.UP)

func cylinder(parent: Node3D,radius: float,width: float,material: Material) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = width
	mesh.radial_segments = 16
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.rotation.z = PI/2
	instance.material_override = material
	parent.add_child(instance)

func _merge_panels() -> void:
	var groups := {}
	for child in get_children():
		if child is MeshInstance3D:
			var material: Material = child.material_override
			if not groups.has(material):
				groups[material] = []
			groups[material].append(child)
	for material in groups:
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		for child in groups[material]:
			surface.append_from(child.mesh,0,child.transform)
			child.queue_free()
		var instance := MeshInstance3D.new()
		instance.mesh = surface.commit()
		instance.material_override = material
		add_child(instance)
