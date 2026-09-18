class_name ChaseCamera
extends Camera3D
var car: DriftCar
var follow_direction := Vector3.FORWARD

func snap() -> void:
	follow_direction = -car.global_basis.z
	global_position = car.global_position - follow_direction * 10 + Vector3.UP * 5.2
	look_at(car.global_position + follow_direction * 6 + Vector3.UP)

func _physics_process(dt: float) -> void:
	var motion := Vector3(car.velocity.x, 0, car.velocity.z)
	var desired := -car.global_basis.z
	if motion.length() > 4:
		desired = desired.lerp(motion.normalized(), 0.65).normalized()
	follow_direction = follow_direction.lerp(desired, 1 - exp(-3.5 * dt)).normalized()
	var target := car.global_position + Vector3.UP * 1.2
	var desired_position := target - follow_direction * (9.5 + car.speed * 0.055) + Vector3.UP * 4.2
	var query := PhysicsRayQueryParameters3D.create(target, desired_position)
	query.exclude = [car.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		desired_position = hit.position + hit.normal * 0.4
	global_position = global_position.lerp(desired_position, 1 - exp(-7 * dt))
	look_at(target + follow_direction * 5)
	fov = lerpf(fov, 66 + car.speed * 0.32, 1 - exp(-2 * dt))
