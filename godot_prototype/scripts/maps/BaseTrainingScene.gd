# BaseTrainingScene.gd
# Shared training map base — flight, targets, HUD, wind, weather, audio, particles, pause
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
var pause_menu: PauseMenu
var ew_active: bool = false
var _paused: bool = false
var _scene_path: String = ""

func _ready() -> void:
	_scene_path = get_tree().current_scene.scene_file_path if get_tree().current_scene else ""
	flight = FlightModel.new()
	flight.reset(Vector3(0, spawn_height, 0))

	if typeof(GameState) != TYPE_NIL and GameState.has_method("reset_run"):
		GameState.reset_run()
		GameState.set_map(map_name.to_lower())

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

	pause_menu = PauseMenu.new()
	pause_menu.name = "PauseMenu"
	add_child(pause_menu)
	pause_menu.resume_pressed.connect(_on_resume)
	pause_menu.restart_pressed.connect(_on_restart)
	pause_menu.main_menu_pressed.connect(_on_main_menu)

	print(map_name, " training ready (Phase A core path)")

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
	if Input.is_action_just_pressed("ui_cancel") or (Input.is_key_pressed(KEY_ESCAPE) and not _paused):
		# edge detect escape via ui_cancel preferred; fallback handled in _unhandled
		pass

	if _paused:
		return
	if flight == null or player == null:
		return

	if Input.is_physical_key_pressed(KEY_J) and not Input.is_physical_key_pressed(KEY_SHIFT):
		# edge-ish: only toggle when just became pressed — use frame flag
		if not has_meta("_j_held"):
			set_meta("_j_held", false)
		if not get_meta("_j_held"):
			ew_active = not ew_active
			set_meta("_j_held", true)
	else:
		set_meta("_j_held", false)

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
		objectives.check_proximity(flight.pos)

	var prog := Vector2i(0, 0)
	if objectives:
		prog = objectives.get_progress()
	var score_val := 0
	if scoring:
		score_val = scoring.get_score()
	if hud:
		hud.update_stats(flight.get_speed(), flight.pos.y, flight.battery, score_val, prog.x, prog.y, map_name)

	if typeof(GameState) != TYPE_NIL and GameState.has_method("update_telemetry"):
		GameState.update_telemetry(flight.get_telemetry())
		GameState.score = score_val

	if audio:
		audio.update_from_telemetry({
			"throttle": flight.throttle,
			"speed": flight.get_speed(),
			"battery": flight.battery,
			"ew_active": ew_active,
			"wind_strength": wind_vec.length()
		})

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if _paused:
				_on_resume()
			else:
				_pause()
			get_viewport().set_input_as_handled()

func _pause() -> void:
	_paused = true
	get_tree().paused = true
	if pause_menu:
		pause_menu.show_pause()

func _on_resume() -> void:
	_paused = false
	get_tree().paused = false
	if pause_menu:
		pause_menu.hide_pause()

func _on_restart() -> void:
	get_tree().paused = false
	_paused = false
	var path := _scene_path
	if path == "" or path == null:
		path = get_tree().current_scene.scene_file_path if get_tree().current_scene else ""
	if path != "":
		get_tree().change_scene_to_file(path)

func _on_main_menu() -> void:
	get_tree().paused = false
	_paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _on_progress(hit: int, total: int) -> void:
	if scoring:
		scoring.add_hit(hit, 100)
	if typeof(GameState) != TYPE_NIL:
		if GameState.has_method("add_score"):
			GameState.add_score(100)
		if GameState.has_method("register_hit"):
			GameState.register_hit()
		GameState.objectives_total = total
