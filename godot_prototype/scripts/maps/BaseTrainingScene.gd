# BaseTrainingScene.gd
# Optional base class for map scenes — uses shared FlightModel + targets + HUD
extends Node3D
class_name BaseTrainingScene

@export var map_name: String = "TRAINING"
@export var wind_preset: String = "field"
@export var spawn_height: float = 12.0
@export var body_color: Color = Color(0.95, 0.55, 0.1)

var flight: FlightModel
var player: Node3D
var hud: TrainingHUD
var scoring: ScoringSystem
var wind_mgr: WindManager
var objectives: ObjectiveManager

func _ready() -> void:
	flight = FlightModel.new()
	flight.reset(Vector3(0, spawn_height, 0))
	scoring = ScoringSystem.new()
	add_child(scoring)
	wind_mgr = WindManager.new()
	wind_mgr.set_preset(wind_preset)
	add_child(wind_mgr)
	objatives = ObjectiveManager.new()
	add_child(objectives)
	objectives.objective_progress.connect(_on_progress)
	_build_world()
	_build_player()
	_build_targets()
	hud = TrainingHUD.new()
	add_child(hud)
	print(map_name, " training ready (core systems)")

func _build_world() -> void:
	pass  # override in subclass

func _build_targets() -> void:
	pass  # override — call objectives.spawn_targets(self, spots)

func _build_player() -> void:
	player = Node3D.new()
	player.name = "Player"
	var visual := DroneVisual.new()
	visual.body_color = body_color
	player.add_child(visual)
	var cam := FPVCamera.new()
	player.add_child(cam)
	player.position = flight.pos
	add_child(player)

func _process(delta: float) -> void:
	if flight == null or player == null:
		return
	flight.wind = wind_mgr.get_wind_at(flight.pos) if wind_mgr else Vector3.ZERO
	flight.read_input(delta)
	flight.step(delta)
	player.position = flight.pos
	player.rotation = flight.get_rotation()
	if player.has_node("FPVCamera"):
		var c = player.get_node("FPVCamera")
		if c.has_method("set_speed"):
			c.set_speed(flight.get_speed())
	objatives.check_proximity(flight.pos)
	var prog := objectives.get_progress()
	hud.update_stats(flight.get_speed(), flight.pos.y, flight.battery, scoring.get_score(), prog.x, prog.y, map_name)
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _on_progress(hit: int, total: int) -> void:
	scoring.add_hit(hit, 100)
