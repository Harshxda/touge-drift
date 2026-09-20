class_name DrivingFeedback
extends Node3D
## Original synthesized audio and a fixed-budget skid trail.
var car: DriftCar
var engine: AudioStreamPlayer
var tires: AudioStreamPlayer
var marks: MultiMesh
var mark_index := 0
var last_left := Vector3.ZERO
var last_right := Vector3.ZERO
var trail_active := false
var elapsed := 0.0
const MARK_BUDGET := 768

func _ready() -> void:
	engine = _loop("res://assets/audio/engine.wav", -20)
	tires = _loop("res://assets/audio/tires.wav", -60)
	marks = MultiMesh.new()
	marks.transform_format = MultiMesh.TRANSFORM_3D
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE
	marks.mesh = mesh
	marks.instance_count = MARK_BUDGET
	for i in range(MARK_BUDGET):
		marks.set_instance_transform(i, Transform3D(Basis.IDENTITY.scaled(Vector3.ZERO), Vector3.ZERO))
	var instance := MultiMeshInstance3D.new()
	instance.multimesh = marks
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("393448")
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	instance.material_override = material
	add_child(instance)

func _loop(path: String, volume: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	var sound := load(path).duplicate() as AudioStreamWAV
	sound.loop_mode = AudioStreamWAV.LOOP_FORWARD
	sound.loop_begin = 0
	# Generated loops are one second; loop offsets count samples, not compressed bytes.
	sound.loop_end = sound.mix_rate
	player.stream = sound
	player.volume_db = volume
	add_child(player)
	if DisplayServer.get_name() != "headless":
		player.play()
	return player

func _notification(what: int) -> void:
	if engine == null:
		return
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		engine.stream_paused = true
		tires.stream_paused = true
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		engine.stream_paused = false
		tires.stream_paused = false

func _exit_tree() -> void:
	engine.stop()
	tires.stop()
	engine.stream = null
	tires.stream = null

func _physics_process(dt: float) -> void:
	var revs := clampf(fmod(car.speed, 8.5) / 8.5, 0, 1)
	engine.pitch_scale = lerpf(engine.pitch_scale, 0.75 + revs * 1.4 + car.throttle * 0.35, 1-exp(-7*dt))
	engine.volume_db = lerpf(engine.volume_db, -23 + car.throttle * 9, 1-exp(-5*dt))
	var sliding := car.is_on_floor() and car.speed > 3 and (absf(car.slip) > 0.18 or car.handbrake)
	var intensity := clampf(absf(car.slip) / 0.7, 0, 1) if sliding else 0.0
	tires.volume_db = lerpf(tires.volume_db, lerpf(-60,-13,intensity), 1-exp(-10*dt))
	tires.pitch_scale = 0.9 + clampf(car.speed/40,0,0.35)
	elapsed += dt
	if elapsed < 0.06:
		return
	elapsed = 0
	var left := car.global_position + car.global_basis * Vector3(-0.88,0.045,1.35)
	var right := car.global_position + car.global_basis * Vector3(0.88,0.045,1.35)
	if sliding and trail_active and left.distance_to(last_left) < 3:
		_mark(last_left,left)
		_mark(last_right,right)
	last_left = left
	last_right = right
	trail_active = sliding

func _mark(a: Vector3, b: Vector3) -> void:
	var length := a.distance_to(b)
	if length < 0.03:
		return
	var z := (b-a).normalized()
	var x := Vector3.UP.cross(z).normalized()
	var y := z.cross(x).normalized()
	var basis := Basis(x,y,z).scaled_local(Vector3(0.20,0.008,length+0.04))
	marks.set_instance_transform(mark_index,Transform3D(basis,(a+b)/2))
	mark_index = (mark_index+1) % MARK_BUDGET
