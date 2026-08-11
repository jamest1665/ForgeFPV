# BaseTrainingScene.gd
# Shared training map base — flight, drone config, HUD, wind, weather, audio, particles, pause, missions, help, trail
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
@export var enable_path_trail: bool = true

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
var help_overlay: HelpOverlay
var path_trail: PathTrail
var drone_db: DroneDatabase
var ew_active: bool = false
var _paused: bool = false
var _scene_path: String = ""
var _mission_finished: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_scene_path = get_tree().current_scene.scene_file_path if get_tree().current_scene else ""
	flight = FlightModel.new()
	flight.reset(Vector3(0, spawn_height, 0))
	_apply_selected_drone()

	if typeof(GameState) != TYPE_NIL and GameState.has_method("reset_run"):
		if typeof(MissionManager) == TYPE_NIL or not MissionManager.has_active_mission():
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
	objectives.all_complete.connect(_on_all_complete)

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

	if enable_path_trail and player:
		path_trail = PathTrail.new()
		path_trail.name = "PathTrail"
		add_child(path_trail)
		path_trail.set_follow(player)

	hud = TrainingHUD.new()
	hud.name = "TrainingHUD"
	add_child(hud)

	pause_menu = PauseMenu.new()
	pause_menu.name = "PauseMenu"
	add_child(pause_menu)
	pause_menu.resume_pressed.connect(_on_resume)
	pause_menu.restart_pressed.connect(_on_restart)
	pause_menu.main_menu_pressed.connect(_on_main_menu)

	help_overlay = HelpOverlay.new()
	help_overlay.name = "HelpOverlay"
	add_child(help_overlay)

	print(map_name, " training ready (Phase C)")

func _apply_selected_drone() -> void:
	drone_db = DroneDatabase.new()
	drone_db._register_defaults()
	var id := "trainer_5inch"
	if typeof(GameState) != TYPE_NIL:
		id = GameState.selected_drone
	var cfg: DroneConfig = drone_db.get_drone(id)
	if cfg:
		cfg.apply_to_flight_model(flight)
		body_color = cfg.body_color
		print("Applied airframe: ", cfg.display_name)

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
	if _paused or _mission_finished:
		return
	if flight == null or player == null:
		return

	if Input.is_physical_key_pressed(KEY_J):
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

	var telem := flight.get_telemetry()
	if typeof(GameState) != TYPE_NIL and GameState.has_method("update_telemetry"):
		GameState.update_telemetry(telem)
		GameState.score = score_val
	if typeof(MissionManager) != TYPE_NIL and MissionManager.has_active_mission():
		MissionManager.update_telemetry(telem)
		var remain: float = MissionManager.get_time_remaining()
		if remain == 0.0:
			_mission_finished = true
			MissionManager.notify_time_expired(score_val, prog.x, prog.y)
			return

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
		elif event.keycode == KEY_H:
			if help_overlay:
				help_overlay.toggle()
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
	if path == "":
		if get_tree().current_scene:
			path = get_tree().current_scene.scene_file_path
	if path != "":
		get_tree().change_scene_to_file(path)

func _on_main_menu() -> void:
	get_tree().paused = false
	_paused = false
	if typeof(MissionManager) != TYPE_NIL:
		MissionManager.abandon()
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

func _on_all_complete(_score_hint: int) -> void:
	if _mission_finished:
		return
	if typeof(MissionManager) != TYPE_NIL and MissionManager.has_active_mission():
		_mission_finished = true
		var prog := objectives.get_progress() if objectives else Vector2i(0, 0)
		var score_val := scoring.get_score() if scoring else 0
		MissionManager.notify_targets_cleared(score_val, prog.x, prog.y)
