# fpv_camera.gd — Phase 1 FPV camera pack (FOV presets, speed FOV, EW noise)
extends Camera3D
class_name FPVCamera

@export var base_fov: float = 100.0
@export var max_fov: float = 125.0
@export var near_override: float = 0.08

var _speed: float = 0.0
var _ew: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	current = true
	if typeof(PilotSettings) != TYPE_NIL:
		base_fov = PilotSettings.fov
	fov = base_fov
	near = near_override
	position = Vector3(0, 0.06, 0.12)

func set_speed(speed: float) -> void:
	_speed = speed
	var boost := clampf(speed * 0.18, 0.0, 22.0)
	fov = clampf(base_fov + boost, base_fov, max_fov)

func apply_ew_jitter(strength: float) -> void:
	_ew = maxf(_ew, strength)

func _process(delta: float) -> void:
	_time += delta
	if _ew > 0.001:
		var s := _ew
		h_offset = sin(_time * 37.0) * s * 0.015 + randf_range(-s, s) * 0.01
		v_offset = cos(_time * 29.0) * s * 0.012 + randf_range(-s, s) * 0.008
		# mild FOV wobble under interference
		fov = clampf(fov + sin(_time * 18.0) * s * 1.5, base_fov - 5.0, max_fov)
		_ew = move_toward(_ew, 0.0, delta * 1.2)
	else:
		h_offset = move_toward(h_offset, 0.0, delta * 2.0)
		v_offset = move_toward(v_offset, 0.0, delta * 2.0)

func set_base_fov(f: float) -> void:
	base_fov = clampf(f, 70.0, 130.0)
	fov = base_fov
