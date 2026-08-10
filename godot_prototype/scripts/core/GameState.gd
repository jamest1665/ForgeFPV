# GameState.gd — Autoload-ready global run state
extends Node

var selected_map: String = "donbas"
var selected_drone: String = "trainer_5inch"
var score: int = 0
var high_score: int = 0
var objectives_hit: int = 0
var objectives_total: int = 0
var last_telemetry: Dictionary = {}

func _ready() -> void:
	print("GameState ready")

func reset_run() -> void:
	score = 0
	objectives_hit = 0
	objectives_total = 0
	last_telemetry = {}

func add_score(points: int) -> void:
	score += points
	if score > high_score:
		high_score = score

func register_hit() -> void:
	objectives_hit += 1

func set_map(map_id: String) -> void:
	selected_map = map_id

func set_drone(drone_id: String) -> void:
	selected_drone = drone_id

func update_telemetry(t: Dictionary) -> void:
	last_telemetry = t

func get_run_summary() -> Dictionary:
	return {
		"score": score,
		"high_score": high_score,
		"objectives_hit": objectives_hit,
		"objectives_total": objectives_total,
		"map": selected_map,
		"drone": selected_drone
	}
