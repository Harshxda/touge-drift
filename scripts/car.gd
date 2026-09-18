class_name DriftCar
extends CharacterBody3D

var assist := DriftAssist.new()
var throttle := 0.0
var brake := 0.0
var steer := 0.0
var handbrake := false
var steering := 0.0
var drifting := false
var slip := 0.0
var speed := 0.0
var gear := 1
var score := 0.0
var banked := 0.0
var combo := 1.0
var drift_time := 0.0
var grace := 0.0
var yaw_speed := 0.0
var wheels: Array[Node3D] = []
var brake_material: StandardMaterial3D
var smoke: GPUParticles3D
var crashed := false

func _ready() -> void:
	floor_snap_length = 2.0
	floor_max_angle = deg_to_rad(55)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.75, 0.8, 4.1)
	shape.shape = box
	shape.position.y = 0.65
	add_child(shape)
	_make_visuals()

func _physics_process(dt: float) -> void:
	var forward := -global_basis.z
	var right := global_basis.x
	speed = Vector2(velocity.x, velocity.z).length()
	var longitudinal := velocity.dot(forward)
	gear = 0 if longitudinal < -0.5 else clampi(1 + int(speed / 8.5), 1, 5)
	var lateral := velocity.dot(right)
	slip = atan2(lateral, maxf(absf(longitudinal), 0.5))
	steering = move_toward(steering, steer, assist.steering_speed * dt)
	if speed > 8.0 and (handbrake or (brake > 0.1 and absf(steering) > 0.45)):
		drifting = true
	if speed < 5.0 or (absf(slip) < 0.12 and absf(steering) < 0.15 and not handbrake):
		drifting = false
	var target_yaw := -steering * clampf(longitudinal / 12.0, -0.65, 1.0) * (1.15 if drifting else 0.83)
	target_yaw += assist.yaw_correction(slip, drifting)
	yaw_speed = lerpf(yaw_speed, target_yaw, 1.0 - exp(-assist.stability * dt))
	rotate_y(yaw_speed * dt)
	var acceleration := throttle * 13.5 * (1.0 - clampf(longitudinal / 43.0, 0.0, 1.0))
	if brake > 0.0:
		acceleration -= brake * (23.0 if longitudinal > 0.8 else 6.0)
	if longitudinal < -6.0:
		acceleration = maxf(acceleration, 0.0)
	velocity += forward * acceleration * dt
	velocity -= right * lateral * minf(assist.lateral_grip(drifting, handbrake) * dt, 1.0)
	velocity -= Vector3(velocity.x, 0, velocity.z) * (0.10 + (0.55 if handbrake else 0.0)) * dt
	velocity.y -= 24.0 * dt
	move_and_slide()
	crashed = false
	for i in get_slide_collision_count():
		if absf(get_slide_collision(i).get_normal().y) < 0.4:
			crashed = true
	if crashed:
		score = 0.0
		combo = 1.0
		drift_time = 0.0
	var valid := speed > 7.0 and absf(slip) > deg_to_rad(12) and absf(slip) < deg_to_rad(70) and not crashed and is_on_floor()
	if valid:
		drift_time += dt
		grace = 1.4
		combo = minf(5.0, 1.0 + floorf(drift_time / 2.5) * 0.5)
		score += speed * absf(slip) * 12.0 * combo * dt
	else:
		grace -= dt
		if grace <= 0.0:
			banked += score
			score = 0.0
			combo = 1.0
			drift_time = 0.0
	brake_material.emission_energy_multiplier = 4.0 if brake > 0 or handbrake else 1.0
	smoke.emitting = valid or (handbrake and speed > 4)
	for wheel in wheels:
		wheel.rotate_x(-longitudinal * dt / 0.34)

func reset_at(point: Vector3, heading: float) -> void:
	global_position = point + Vector3.UP * 0.4
	rotation = Vector3(0, heading, 0)
	velocity = Vector3.ZERO
	yaw_speed = 0
	drifting = false
	score = 0
	combo = 1
	drift_time = 0

func _make_visuals() -> void:
	var paint := StandardMaterial3D.new()
	paint.albedo_color = Color("c6d7cf")
	paint.metallic = 0.65
	paint.roughness = 0.28
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color("101e2a")
	glass.metallic = 0.5
	_mesh_box(Vector3(1.86, 0.52, 4.35), Vector3(0, 0.64, 0), paint)
	_mesh_box(Vector3(1.55, 0.56, 1.85), Vector3(0, 1.12, 0.1), glass)
	_mesh_box(Vector3(1.6, 0.09, 1.4), Vector3(0, 1.43, 0.18), paint)
	_mesh_box(Vector3(1.95, 0.10, 0.42), Vector3(0, 1.12, 1.85), paint)
	var trim := StandardMaterial3D.new()
	trim.albedo_color = Color("87949c")
	trim.metallic = 0.8
	_mesh_box(Vector3(0.16, 0.16, 0.30), Vector3(-0.6, 0.4, 2.24), trim)
	var rubber := StandardMaterial3D.new()
	rubber.albedo_color = Color("101217")
	for x in [-0.94, 0.94]:
		for z in [-1.35, 1.35]:
			var wheel := MeshInstance3D.new()
			var cylinder := CylinderMesh.new()
			cylinder.top_radius = 0.35
			cylinder.bottom_radius = 0.35
			cylinder.height = 0.24
			cylinder.radial_segments = 12
			wheel.mesh = cylinder
			wheel.material_override = rubber
			wheel.rotation.z = PI / 2
			wheel.position = Vector3(x, 0.36, z)
			add_child(wheel)
			wheels.append(wheel)
			var rim := MeshInstance3D.new()
			var disc := CylinderMesh.new()
			disc.top_radius = 0.24
			disc.bottom_radius = 0.24
			disc.height = 0.255
			disc.radial_segments = 8
			rim.mesh = disc
			rim.material_override = trim
			wheel.add_child(rim)
	brake_material = StandardMaterial3D.new()
	brake_material.albedo_color = Color("ff352c")
	brake_material.emission_enabled = true
	brake_material.emission = Color("ff2015")
	var lamp := StandardMaterial3D.new()
	lamp.emission_enabled = true
	lamp.emission = Color("dcefff")
	lamp.emission_energy_multiplier = 3
	for x in [-0.62, 0.62]:
		_mesh_box(Vector3(0.52, 0.16, 0.08), Vector3(x, 0.74, 2.19), brake_material)
		_mesh_box(Vector3(0.52, 0.15, 0.08), Vector3(x, 0.74, -2.19), lamp)
		var light := SpotLight3D.new()
		light.position = Vector3(x, 0.86, -2.2)
		light.rotation.x = -0.08
		light.spot_range = 65
		light.spot_angle = 29
		light.light_energy = 3
		light.light_color = Color("d9e8ff")
		add_child(light)
	smoke = GPUParticles3D.new()
	smoke.position = Vector3(0, 0.35, 1.4)
	smoke.amount = 48
	smoke.lifetime = 1.4
	smoke.visibility_aabb = AABB(Vector3(-20, -3, -20), Vector3(40, 12, 40))
	var process := ParticleProcessMaterial.new()
	process.direction = Vector3(0, 1, 1)
	process.spread = 35
	process.initial_velocity_min = 0.5
	process.initial_velocity_max = 2.0
	process.gravity = Vector3(0, 0.5, 0)
	process.scale_min = 0.35
	process.scale_max = 1.2
	process.color = Color(0.65, 0.72, 0.8, 0.22)
	smoke.process_material = process
	var puff := SphereMesh.new()
	puff.radial_segments = 6
	puff.rings = 3
	var mist := StandardMaterial3D.new()
	mist.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mist.vertex_color_use_as_albedo = true
	mist.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	puff.material = mist
	smoke.draw_pass_1 = puff
	add_child(smoke)

func _mesh_box(size: Vector3, pos: Vector3, material: Material) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = material
	mesh.position = pos
	add_child(mesh)
