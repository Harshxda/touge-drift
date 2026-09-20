extends Node3D
var track: TougeTrack
var car: DriftCar
var camera: ChaseCamera
var hud: TouchHUD
var nearest := 0
var checkpoint := 0
var low_quality := false
var practice_mode := true
var settings: Environment
var sun: DirectionalLight3D
var sky_material: ProceduralSkyMaterial

func _ready() -> void:
	var environment := WorldEnvironment.new()
	settings = Environment.new()
	settings.background_mode = Environment.BG_SKY
	sky_material = ProceduralSkyMaterial.new()
	sky_material.sky_curve = 0.16
	sky_material.ground_bottom_color = Color("44385e")
	var sky := Sky.new()
	sky.sky_material = sky_material
	settings.sky = sky
	settings.background_color = Color("101e30")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("748caa")
	settings.ambient_light_energy = 0.65
	settings.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	settings.fog_enabled = true
	settings.fog_sky_affect = 0.05
	settings.fog_light_color = Color("182b3c")
	settings.fog_density = 0.0018
	environment.environment = settings
	add_child(environment)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-38, -30, 0)
	sun.light_color = Color("8aa8ce")
	sun.light_energy = 0.65
	add_child(sun)
	track = TougeTrack.new()
	add_child(track)
	car = DriftCar.new()
	add_child(car)
	var feedback := DrivingFeedback.new()
	feedback.car = car
	add_child(feedback)
	camera = ChaseCamera.new()
	camera.car = car
	camera.far = 1200
	add_child(camera)
	camera.current = true
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = TouchHUD.new()
	hud.car = car
	layer.add_child(hud)
	hud.reset_requested.connect(restart)
	hud.mode_requested.connect(toggle_mode)
	hud.quality_requested.connect(toggle_quality)
	restart()
	_update_atmosphere(0)

func restart() -> void:
	checkpoint = 0
	nearest = 0
	car.banked = 0
	hud.finished = false
	hud.practice_mode = practice_mode
	if practice_mode:
		car.reset_at(TougeTrack.PRACTICE_SPAWN, 0)
		camera.snap()
	else:
		_respawn(0)

func toggle_mode() -> void:
	practice_mode = not practice_mode
	restart()

func _respawn(index: int) -> void:
	var direction := track.tangent(index)
	car.reset_at(track.points[index], atan2(-direction.x, -direction.z))
	camera.snap()

func toggle_quality() -> void:
	low_quality = not low_quality
	get_viewport().scaling_3d_scale = 0.60 if low_quality else 0.75
	car.smoke.amount = 24 if low_quality else 48

func _physics_process(_dt: float) -> void:
	if practice_mode:
		hud.progress = 0.0
		_update_atmosphere(0)
		if car.position.y < 80:
			restart()
		elif car.position.z < -2 and absf(car.position.x) < 6:
			practice_mode = false
			hud.practice_mode = false
			car.score = 0
			car.banked = 0
		else:
			return
	var best := INF
	for i in range(maxi(0, nearest - 12), mini(track.points.size(), nearest + 15)):
		var distance := car.global_position.distance_squared_to(track.points[i])
		if distance < best:
			best = distance
			nearest = i
	if best < 64 and nearest > checkpoint:
		checkpoint = nearest
	hud.progress = track.distances[checkpoint] / track.total_length
	_update_atmosphere(hud.progress)
	if car.global_position.y < track.points[nearest].y - 10:
		_respawn(checkpoint)
	if checkpoint >= track.points.size() - 4 and not hud.finished:
		hud.finished = true
		car.banked += car.score
		car.score = 0

func _update_atmosphere(progress: float) -> void:
	var night := smoothstep(0.10,0.92,progress)
	sky_material.sky_top_color = Color("e3d77a").lerp(Color("24213f"),night)
	sky_material.sky_horizon_color = Color("f8df9a").lerp(Color("71618e"),night)
	sky_material.ground_horizon_color = sky_material.sky_horizon_color
	settings.ambient_light_color = Color("c2a5d8").lerp(Color("8c8aba"),night)
	settings.ambient_light_energy = lerpf(0.75,0.55,night)
	settings.fog_light_color = Color("b5a5bd").lerp(Color("4c466c"),night)
	settings.fog_density = lerpf(0.0015,0.0022,night)
	sun.light_color = Color("ffe3b0").lerp(Color("a29ccc"),night)
	sun.light_energy = lerpf(1.15,0.45,night)
	sun.rotation_degrees.x = lerpf(-26,-12,night)
