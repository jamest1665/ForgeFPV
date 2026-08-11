# TangentialController.gd — orbit / ring path around a focus point
extends RefCounted
class_name TangentialController

var center: Vector3 = Vector3.ZERO
var radius: float = 40.0
var height: float = 12.0
var angular_speed: float = 0.35  # rad/s
var clockwise: bool = true

func set_ring(p_center: Vector3, p_radius: float, p_height: float = 12.0) -> void:
	center = p_center
	radius = maxf(p_radius, 5.0)
	height = p_height

func desired_velocity_for(agent_pos: Vector3, phase_offset: float, time_sec: float) -> Vector3:
	var angle := time_sec * angular_speed + phase_offset
	if clockwise:
		angle = -angle
	var on_ring := center + Vector3(cos(angle) * radius, height, sin(angle) * radius)
	var tangent := Vector3(-sin(angle), 0.0, cos(angle))
	if clockwise:
		tangent = -tangent
	var to_ring := on_ring - agent_pos
	# blend radial correction with tangential motion
	return (tangent * radius * angular_speed) + to_ring * 0.35

func slot_position(index: int, total: int, time_sec: float = 0.0) -> Vector3:
	var step := TAU / maxf(float(total), 1.0)
	var angle := step * float(index) + time_sec * angular_speed
	if clockwise:
		angle = -angle
	return center + Vector3(cos(angle) * radius, height, sin(angle) * radius)
