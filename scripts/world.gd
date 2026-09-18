extends Node3D
var track: TougeTrack
var car: DriftCar
var camera: ChaseCamera
var hud: TouchHUD
var nearest := 0
var checkpoint := 0
var low_quality := false

func _ready() -> void:
	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("101e30")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("748caa")
	settings.ambient_light_energy = 0.65
	settings.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	settings.fog_enabled = true
	settings.fog_light_color = Color("182b3c")
	settings.fog_density = 0.0018
	environment.environment = settings
	add_child(environment)
	var moon := DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-38, -30, 0)
	moon.light_color = Color("8aa8ce")
	moon.light_energy = 0.65
	add_child(moon)
	track = TougeTrack.new()
	add_child(track)
	car = DriftCar.new()
	add_child(car)
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
	hud.quality_requested.connect(toggle_quality)
	restart()

func restart() -> void:
	checkpoint = 0
	nearest = 0
	car.banked = 0
	hud.finished = false
	_respawn(0)

func _respawn(index: int) -> void:
	var direction := track.tangent(index)
	car.reset_at(track.points[index], atan2(-direction.x, -direction.z))
	camera.snap()

func toggle_quality() -> void:
	low_quality = not low_quality
	get_viewport().scaling_3d_scale = 0.60 if low_quality else 0.75
	car.smoke.amount = 24 if low_quality else 48

func _physics_process(_dt: float) -> void:
	var best := INF
	for i in range(maxi(0, nearest - 12), mini(track.points.size(), nearest + 15)):
		var distance := car.global_position.distance_squared_to(track.points[i])
		if distance < best:
			best = distance
			nearest = i
	if best < 64 and nearest > checkpoint:
		checkpoint = nearest
	hud.progress = track.distances[checkpoint] / track.total_length
	if car.global_position.y < track.points[nearest].y - 10:
		_respawn(checkpoint)
	if checkpoint >= track.points.size() - 4 and not hud.finished:
		hud.finished = true
		car.banked += car.score
		car.score = 0
