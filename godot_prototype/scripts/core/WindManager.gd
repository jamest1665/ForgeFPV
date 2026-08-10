# WindManager.gd — simple wind field for training maps
extends Node
class_name WindManager

@export var base_wind: Vector3 = Vector3(2.0, 0.0, 1.0)
@export var turbulence: float = 0.6
@export var enabled: bool = true

var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta

func get_wind_at(_pos: Vector3) -> Vector3:
	if not enabled:
		return Vector3.ZERO
	var turb := Vector3(
		sin(_time * 1.7) * turbulence,
		sin(_time * 2.3) * turbulence * 0.3,
		cos(_time * 1.1) * turbulence
	)
	return base_wind + turb

func set_preset(name: String) -> void:
	match name:
		"calm":
			base_wind = Vector3(0.5, 0, 0.2)
			turbulence = 0.2
		"field":
			base_wind = Vector3(3.0, 0, 1.5)
			turbulence = 0.8
		"urban":
			base_wind = Vector3(1.5, 0.5, 1.0)
			turbulence = 1.2
		"arctic":
			base_wind = Vector3(5.0, 0, 3.0)
			turbulence = 1.5
		"coastal":
			base_wind = Vector3(4.0, 0.2, 2.0)
			turbulence = 1.0
		_:
			base_wind = Vector3(2.0, 0, 1.0)
			turbulence = 0.6
