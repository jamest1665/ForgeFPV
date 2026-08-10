# fpv_camera.gd
# Rate-mode FPV camera helper — attach under drone root
extends Camera3D
class_name FPVCamera

@export var base_fov: float = 100.0
@export var speed_fov_boost: float = 12.0
@export var max_fov: float = 120.0

var _speed: float = 0.0

func _ready() -> void:
	current = true
	fov = base_fov
	position = Vector3(0, 0.08, 0.15)

func set_speed(speed: float) -> void:
	_speed = speed
	fov = clampf(base_fov + speed * 0.15, base_fov, max_fov)

func apply_ew_jitter(strength: float) -> void:
	if strength <= 0.0:
		return
	h_offset = randf_range(-strength, strength) * 0.02
	v_offset = randf_range(-strength, strength) * 0.02
