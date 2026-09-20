class_name DriftAssist
extends Resource

@export_range(0.0, 1.0) var drift_assist := 0.82
@export var countersteer_strength := 2.4
@export var rear_grip := 5.5
@export var steering_speed := 5.5
@export var stability := 3.5

func yaw_correction(slip: float, drifting: bool) -> float:
	var limit := deg_to_rad(45.0 if drifting else 8.0)
	return -signf(slip) * maxf(absf(slip) - limit, 0.0) * countersteer_strength * drift_assist

func lateral_grip(drifting: bool, handbrake: bool, throttle := 0.0) -> float:
	if handbrake:
		return 0.35
	return lerpf(1.15, 0.60, throttle) if drifting else rear_grip
