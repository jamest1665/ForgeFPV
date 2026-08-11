# BaseTrainingScene.gd
# Shared training map base — flight, targets, HUD, wind, weather, audio, particles
extends Node3D
class_name BaseTrainingScene

@export var map_name: String = "TRAINING"
@export var wind_preset: String = "field"
@export var weather_preset: String = "clear"
@export var spawn_height: float = 12.0
@export var body_color: Color = Color(0.95, 0.55, 0.1)
@export var enable_audio: bool = true
@export var enable_weather: bool = true
@export var enable_wind_particles: bool = true

var flight: FlightModel
var player: Node3D
var hud: TrainingHUD
var scoring: ScoringSystem
var wind_mgr: WindManager
var objectives: ObjectiveManager
var audio: AudioManager
var weather: WeatherSystem
var wind_fx: WindParticleSystem
var ew_active: bool = false

func _ready() -> void:
	flight = FlightModel.new()
	flight.reset(Vector3(0, spawn_height, 0))

	scoring = ScoringSystem.new()
	scoring.name = "ScoringSystem"
	add_child(scoring)

	wind_mgr = WindManager.new()
	wind_mgr.name = "WindManager"
	wind_mgr.set_preset(wind_preset)
	add_child(wind_mgr)

	objectives = ObjectiveManager.new()
	objectives.name = "ObjectiveManager"
	add_child(objectives)
	objectives.objective_progress.connect(_on_progress)

	if enable_weather:
		weather = WeatherSystem.new()
		weather.name = "WeatherSystem"
		add_child(weather)
		weather.set_preset(weather_preset)

	if enable_audio:
		audio = AudioManager.new()
		audio.name = "AudioManager"
		add_child(audio)

	_build_world()
	_build_player()
	_build_targets()

	if enable_wind_particles:
		wind_fx = WindParticleSystem.new()
		wind_fx.name = "WindParticleSystem"
		add_child(wind_fx)
		wind_fx.set_wind_manager(wind_mgr)
		if player:
			wind_fx.set_player(player)
		_apply_particle_look()

	hud = TrainingHUD.new()
	hud.name = "TrainingHUD"
	add_child(hud)
	print(map_name, " training ready (flight+wind+weather+audio+particles)")

func _build_world() -> void:
	pass

func _build_targets() -> void:
	pass

func _build_player() -> void:
	player = Node3D.new()
	player.name = "Player"
	var visual := DroneVisual.new()
	visual.body_color = body_color
	player.add_child(visual)
	var cam := FPVCamera.new()
	cam.name = "FPVCamera"
	player.add_child(cam)
	player.position = flight.pos
	add_child(player)

func _apply_particle_look() -> void:
	if wind_fx == null:
		return
	match wind_preset:
		"arctic":
			wind_fx.set_arctic_look()
		"urban":
			wind_fx.set_urban_look()
		"coastal", "field":
			wind_fx.set_desert_look()
		_:
			pass

func _process(delta: float) -> void:
	if flight == null or player == null:
		return

	# Toggle EW with J (optional training stressor)
	if Input.is_physical_key_pressed(KEY_J):
		ew_active = not ew_active

	var wind_vec := Vector3.ZERO
	if wind_mgr:
		wind_vec = wind_mgr.get_wind_at(flight.pos)
	flight.wind = wind_vec
	flight.read_input(delta)
	flight.step(delta)

	player.position = flight.pos
	player.rotation = flight.get_rotation()

	if player.has_node("FPVCamera"):
		var c = player.get_node("FPVCamera")
		if c.has_method("set_speed"):
			c.set_speed(flight.get_speed())
		if c.has_method("apply_ew_jitter") and ew_active:
			c.apply_ew_jitter(0.6)

	if objectives:
		objatives.check_proximity(flight.pos)

	var prog := Vector2i(0, 0)
	if objectives:
		prog = objectives.get_progress()
	var score_val := 0
	if scoring:
		score_val = scoring.get_score()
	if hud:
		hud.update_stats(flight.get_speed(), flight.pos.y, flight.battery, score_val, prog.x, prog.y, map_name)

	if audio:
		audio.update_from_telemetry({
			"throttle": flight.throttle,
			"speed": flight.get_speed(),
			"battery": flight.battery,
			"ew_active": ew_active,
			"wind_strength": wind_vec.length()
		})

	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _on_progress(hit: int, _total: int) -> void:
	if scoring:
		scoring.add_hit(hit, 100)
