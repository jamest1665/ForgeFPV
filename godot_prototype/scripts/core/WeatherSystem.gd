# WeatherSystem.gd
# ForgeFPV — weather presets that drive wind bias, fog, and ambient feel
# Integrates with WindManager when present on the same parent/scene

extends Node
class_name WeatherSystem

signal weather_changed(preset_name: String)

@export var current_preset: String = "clear"
@export var fog_enabled: bool = true
@export var apply_environment: bool = true

var _time: float = 0.0
var _wind_bias: Vector3 = Vector3.ZERO
var _turbulence_scale: float = 1.0
var _fog_density: float = 0.0
var _visibility: float = 1.0  # 1 = clear, 0 = near zero
var _precip: float = 0.0
var env_node: WorldEnvironment
var env: Environment

func _ready() -> void:
	_ensure_environment()
	set_preset(current_preset)
	print("WeatherSystem ready preset=", current_preset)

func _process(delta: float) -> void:
	_time += delta
	if apply_environment and env and fog_enabled:
		# gentle flicker for fog in storm
		var flicker := 1.0 + sin(_time * 0.7) * 0.05 * _precip
		env.fog_density = _fog_density * flicker

func _ensure_environment() -> void:
	if not apply_environment:
		return
	# Prefer existing WorldEnvironment in tree
	var existing := get_tree().current_scene.find_child("WorldEnvironment", true, false) if get_tree().current_scene else null
	if existing and existing is WorldEnvironment:
		env_node = existing
		env = env_node.environment
		if env == null:
			env = Environment.new()
			env_node.environment = env
		return
	env_node = WorldEnvironment.new()
	env_node.name = "WorldEnvironment"
	env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.45, 0.55, 0.7)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.6, 0.65, 0.7)
	env.ambient_light_energy = 0.6
	env.fog_enabled = true
	env.fog_light_color = Color(0.7, 0.75, 0.8)
	env_node.environment = env
	var parent := get_parent()
	if parent:
		parent.add_child(env_node)
	else:
		add_child(env_node)

func set_preset(name: String) -> void:
	current_preset = name
	match name:
		"clear":
			_wind_bias = Vector3(1.0, 0, 0.5)
			_turbulence_scale = 0.5
			_fog_density = 0.0005
			_visibility = 1.0
			_precip = 0.0
			_set_sky(Color(0.45, 0.62, 0.85), 0.7)
		"overcast":
			_wind_bias = Vector3(2.5, 0, 1.2)
			_turbulence_scale = 0.9
			_fog_density = 0.002
			_visibility = 0.75
			_precip = 0.0
			_set_sky(Color(0.4, 0.42, 0.45), 0.45)
		"fog":
			_wind_bias = Vector3(0.8, 0, 0.4)
			_turbulence_scale = 0.4
			_fog_density = 0.012
			_visibility = 0.35
			_precip = 0.0
			_set_sky(Color(0.55, 0.58, 0.6), 0.35)
		"rain":
			_wind_bias = Vector3(4.0, 0.2, 2.0)
			_turbulence_scale = 1.3
			_fog_density = 0.004
			_visibility = 0.55
			_precip = 0.7
			_set_sky(Color(0.32, 0.35, 0.4), 0.4)
		"snow":
			_wind_bias = Vector3(3.5, 0.1, 2.5)
			_turbulence_scale = 1.1
			_fog_density = 0.006
			_visibility = 0.5
			_precip = 0.5
			_set_sky(Color(0.65, 0.7, 0.78), 0.5)
		"storm":
			_wind_bias = Vector3(8.0, 0.5, 5.0)
			_turbulence_scale = 2.0
			_fog_density = 0.008
			_visibility = 0.4
			_precip = 1.0
			_set_sky(Color(0.22, 0.24, 0.28), 0.3)
		"arctic":
			_wind_bias = Vector3(6.0, 0, 4.0)
			_turbulence_scale = 1.6
			_fog_density = 0.003
			_visibility = 0.65
			_precip = 0.2
			_set_sky(Color(0.7, 0.78, 0.88), 0.55)
		"coastal":
			_wind_bias = Vector3(5.0, 0.2, 2.5)
			_turbulence_scale = 1.2
			_fog_density = 0.0025
			_visibility = 0.7
			_precip = 0.15
			_set_sky(Color(0.4, 0.55, 0.72), 0.6)
		_:
			_wind_bias = Vector3(2.0, 0, 1.0)
			_turbulence_scale = 1.0
			_fog_density = 0.001
			_visibility = 0.9
			_precip = 0.0
			_set_sky(Color(0.45, 0.55, 0.7), 0.6)
	if env:
		env.fog_enabled = fog_enabled and _fog_density > 0.0001
		env.fog_density = _fog_density
	_sync_wind_manager()
	weather_changed.emit(current_preset)
	print("WeatherSystem: preset -> ", current_preset)

func _set_sky(bg: Color, ambient_energy: float) -> void:
	if env == null:
		return
	env.background_color = bg
	env.ambient_light_color = bg.lightened(0.15)
	env.ambient_light_energy = ambient_energy
	env.fog_light_color = bg.lightened(0.1)

func _sync_wind_manager() -> void:
	# If a WindManager sibling/child exists, push bias
	var wm := _find_wind_manager()
	if wm == null:
		return
	if wm.has_method("set_preset") == false:
		# direct property push
		if "base_wind" in wm:
			wm.base_wind = _wind_bias
		if "turbulence" in wm:
			wm.turbulence = 0.6 * _turbulence_scale
		return
	# map weather to nearest wind preset name when useful
	match current_preset:
		"clear":
			wm.set_preset("calm")
		"urban", "overcast":
			wm.set_preset("urban")
		"arctic", "snow":
			wm.set_preset("arctic")
		"coastal", "rain", "storm":
			wm.set_preset("coastal")
		_:
			wm.set_preset("field")
	if "base_wind" in wm:
		wm.base_wind = _wind_bias
	if "turbulence" in wm:
		wm.turbulence = maxf(0.2, 0.6 * _turbulence_scale)

func _find_wind_manager() -> Node:
	if has_node("WindManager"):
		return get_node("WindManager")
	var parent := get_parent()
	if parent and parent.has_node("WindManager"):
		return parent.get_node("WindManager")
	if get_tree().current_scene:
		return get_tree().current_scene.find_child("WindManager", true, false)
	return null

func get_wind_bias() -> Vector3:
	return _wind_bias

func get_turbulence_scale() -> float:
	return _turbulence_scale

func get_visibility() -> float:
	return _visibility

func get_precip() -> float:
	return _precip

func get_fog_density() -> float:
	return _fog_density

func list_presets() -> Array:
	return ["clear", "overcast", "fog", "rain", "snow", "storm", "arctic", "coastal"]
